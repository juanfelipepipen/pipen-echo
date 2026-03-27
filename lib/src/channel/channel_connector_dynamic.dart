import 'dart:async';
import 'package:collection/collection.dart';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:pipen_echo/pipen_echo.dart';

typedef ChannelConnectors = Map<PusherPrivateChannel, PrivateChannel>;
typedef ChannelEventListeners =
    Map<KChannelEvent, StreamSubscription<ChannelReadEvent>>;

class ChannelConnectorDynamic {
  ChannelConnectorDynamic({required this.client, required this.options});

  final PusherChannelsClient client;
  final PusherEchoOptions options;

  List<PusherPrivateChannel> _channels = [];
  ChannelConnectors _channelConnectors = {};
  ChannelEventListeners _listeners = {};

  /// Connect to channel
  Future<void> connect() async {
    options.onChangeState?.call(.connecting);
    options.outputs?.onConnecting?.call().output();

    // When connection is established subscribe to channels
    client.onConnectionEstablished.listen((_) {
      print('Connected to pusher channel');
      options.onChangeState?.call(.connected);
      options.outputs?.onConnectionEstablished?.call().output();
      _reconnected();
    });

    // On connection error
    client.pusherErrorEventStream.listen((e) {
      print('Error in pusher channel');
      print(e);
    });

    await client.connect();
  }

  /// Subscribe to channel
  void subscribe(PusherPrivateChannel channel) {
    final channelExists =
        _channels.firstWhereOrNull(
          (e) => e.channelName == channel.channelName,
        ) !=
        null;

    if (!channelExists) {
      _channels.add(channel);
      _connectChannel(channel);
    }
  }

  /// Bind channel events
  void attach(KChannelEvent event) {
    PusherPrivateChannel? channel = _channels.firstWhereOrNull(
      (e) => e.channelName == event.channelName,
    );

    if (channel == null) {
      channel = event.toChannel();
      subscribe(channel);
    }

    // Stop if event already exists
    if (channel.events.contains(event)) {
      return;
    }

    // Add event to channel
    channel.events.add(event);

    // Bind event
    if (_channelConnectors[channel] case PrivateChannel connector) {
      print('Bind event: ' + event.eventName);
      final eventListener = connector.bind(event.eventName).listen((data) {
        event.onData(data.data.toString());
      });
      _listeners[event] = eventListener;
    }
  }

  /// Unattach event listener
  void unattach(KChannelEvent event) {
    final hasListener = _listeners.keys.toList().indexOf(event) != -1;

    // Remove from event listener
    if (hasListener) {
      _listeners[event]?.cancel();
      _listeners.remove(event);
    }

    // Remove from channel events
    final channel = _channels.firstWhereOrNull(
      (e) => e.channelName == event.channelName,
    );

    channel?.events.remove(event);
  }

  /// Connect to pusher channel
  void _connectChannel(PusherPrivateChannel channel) {
    print('Connecting to channel: ' + channel.channelName);

    final connector = client.privateChannel(
      channel.channelName,
      authorizationDelegate: pusher.authorizationDelegate,
    );

    connector.whenSubscriptionSucceeded().listen((data) {
      print('success to channel: ' + channel.channelName);
      options.onChangeState?.call(ChannelConnectionState.connected);
      options.outputs?.onChannelConnected?.call(data.channelName).output();
    });

    connector.onSubscriptionError().listen((data) {
      options.onChangeState?.call(ChannelConnectionState.reconnecting);
      options.outputs?.onSubscriptionError?.call(data.channelName).output();
    });

    connector.onAuthenticationSubscriptionFailed().listen((data) {
      options.onChangeState?.call(ChannelConnectionState.reconnecting);
      options.outputs?.onAuthenticationSubscriptionFailed
          ?.call(data.channelName)
          .output();
    });

    connector.subscribe();
    _channelConnectors[channel] = connector;
  }

  /// Check if reconnect to channels is required
  void _reconnected() {
    if (_channels.isEmpty) {
      return;
    }

    // Cancel current subscriptions
    for (final key in _listeners.keys) {
      _listeners[key]?.cancel();
    }

    // Connect to channels
    for (final channel in _channels) {
      _connectChannel(channel);
    }

    // Bind events
    for (final channel in _channels) {
      for (final event in channel.events) {
        attach(event);
      }
    }
  }

  /// Close channel
  void close() {
    options.onChangeState?.call(.closed);
    client.disconnect();
    client.dispose();
  }
}
