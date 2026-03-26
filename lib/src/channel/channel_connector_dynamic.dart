import 'dart:async';

import 'package:collection/collection.dart';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:pipen_echo/pipen_echo.dart';

class ChannelConnectorDynamic {
  ChannelConnectorDynamic({required this.client, required this.options});

  final PusherChannelsClient client;
  final PusherEchoOptions options;
  PrivateChannel? channel;

  List<PusherPrivateChannel> _channels = [];
  Map<String, PrivateChannel> _channelConnectors = {};
  Map<ChannelEvent, StreamSubscription<ChannelReadEvent>> _listeners = {};

  /// Connect to channel
  Future<void> connect() async {
    options.onChangeState?.call(.connecting);
    options.outputs?.onConnecting?.call().output();

    // When connection is established subscribe to channels
    client.onConnectionEstablished.listen((_) {
      print('todo ok');
      options.onChangeState?.call(.connected);
      options.outputs?.onConnectionEstablished?.call().output();
    });

    // On connection error
    client.pusherErrorEventStream.listen((e) {
      print(e);
    });

    await client.connect();
  }

  /// Subscribe to channel
  void subscribe(PusherPrivateChannel channel) {
    final channelInConnector = _channels.firstWhereOrNull(
      (e) => e.channelName == channel.channelName,
    );

    if (channelInConnector == null) {
      _channels.add(channel);
      _connectChannel(channel);
    }
  }

  /// Connect to pusher channel
  void _connectChannel(PusherPrivateChannel channel) {
    print('pusher|connecting');
    final channelConnector = client.privateChannel(
      channel.channelName,
      authorizationDelegate: pusher.authorizationDelegate,
    );

    channelConnector.whenSubscriptionSucceeded().listen((data) {
      options.onChangeState?.call(ChannelConnectionState.connected);
      options.outputs?.onChannelConnected?.call(data.channelName).output();
    });

    channelConnector.onSubscriptionError().listen((data) {
      options.onChangeState?.call(ChannelConnectionState.reconnecting);
      options.outputs?.onSubscriptionError?.call(data.channelName).output();
    });

    channelConnector.onAuthenticationSubscriptionFailed().listen((data) {
      options.onChangeState?.call(ChannelConnectionState.reconnecting);
      options.outputs?.onAuthenticationSubscriptionFailed
          ?.call(data.channelName)
          .output();
    });

    channelConnector.subscribe();
    _channelConnectors[channel.channelName] = channelConnector;
  }

  /// Bind channel events
  void attach({required String channelName, required ChannelEvent event}) {
    final channelConnector = _channelConnectors['private-' + channelName];

    if (channelConnector != null) {
      final subscriptionListener = channelConnector
          .bind(event.eventName)
          .listen((data) {
            event.onData(data.data.toString());
          });
      _listeners[event] = subscriptionListener;
    }
  }

  /// Unattach event listener
  void unattach(ChannelEvent event) {
    final exists = _listeners.keys.toList().indexOf(event) != -1;

    if (exists) {
      _listeners[event]?.cancel();
      _listeners.remove(event);
    }
  }

  /// Close channel
  void close() {
    options.onChangeState?.call(.closed);
    client.disconnect();
    client.dispose();
  }
}
