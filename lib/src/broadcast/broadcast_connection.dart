import 'dart:async';
import 'package:collection/collection.dart';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:pipen_echo/pipen_echo.dart';

typedef ChannelConnectors = Map<PusherPrivateChannel, PrivateChannel>;
typedef ChannelEventListeners =
    Map<ChannelEvent, StreamSubscription<ChannelReadEvent>>;

class BroadcastConnection {
  BroadcastConnection({required this.client, required this.configs});

  /// Pusher client
  final PusherChannelsClient client;

  /// Pusher client configs
  final BroadcastConfig configs;

  /// List of channel info for connect
  final List<PusherPrivateChannel> _channels = [];

  /// Map of channel info and her current connection to pusher
  final ChannelConnectors _channelConnectors = {};

  /// List of event listener in a channel
  final ChannelEventListeners _eventListeners = {};

  /// Connect to broadcast
  Future<void> connect() async {
    configs.echoOptions.onChangeState?.call(.connecting);
    configs.echoOptions.outputs?.onConnecting?.call().output();

    // When connection is established subscribe to channels
    client.onConnectionEstablished.listen((_) {
      print('Echo - Connected to Pusher WebSocket');
      configs.echoOptions.onChangeState?.call(.connected);
      configs.echoOptions.outputs?.onConnectionEstablished?.call().output();
      _connectChannels();
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
    print('Subscribe to channel');
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
  void attach(ChannelEvent event) {
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

    print(_channelConnectors[channel]);
    // Bind event
    if (_channelConnectors[channel] case PrivateChannel connector) {
      print('Echo - Channel: ${event.channelName} | Event: ${event.eventName}');
      final eventListener = connector.bind(event.eventName).listen((data) {
        print(data.data);
        event.onData(data.data.toString());
      });
      _eventListeners[event] = eventListener;
    }
  }

  /// Unattach event listener
  void unattach(ChannelEvent event) {
    final hasListener = _eventListeners.keys.toList().contains(event);

    // Remove from event listener
    if (hasListener) {
      _eventListeners[event]?.cancel();
      _eventListeners.remove(event);
    }

    // Remove from channel events
    final channel = _channels.firstWhereOrNull(
      (e) => e.channelName == event.channelName,
    );

    channel?.events.remove(event);
  }

  /// Connect to pusher channel
  void _connectChannel(PusherPrivateChannel channel) {
    final hasConnector = _channelConnectors.containsKey(channel);

    print('Echo - Connecting to channel: [${channel.channelName}]');

    final connector = hasConnector
        ? _channelConnectors[channel]!
        : client.privateChannel(
            channel.channelName,
            authorizationDelegate: configs.authorizationDelegate,
          );

    if (!hasConnector) {
      connector.whenSubscriptionSucceeded().listen((data) {
        print('Echo - Success connection to channel: [${channel.channelName}]');
        configs.echoOptions.onChangeState?.call(.connected);
        configs.echoOptions.outputs?.onChannelConnected
            ?.call(data.channelName)
            .output();
      });

      connector.onSubscriptionError().listen((data) {
        print('Subscription channel ERROR');
        print(data);
        configs.echoOptions.onChangeState?.call(.reconnecting);
        configs.echoOptions.outputs?.onSubscriptionError
            ?.call(data.channelName)
            .output();
      });

      connector.onAuthenticationSubscriptionFailed().listen((data) {
        configs.echoOptions.onChangeState?.call(.reconnecting);
        configs.echoOptions.outputs?.onAuthenticationSubscriptionFailed
            ?.call(data.channelName)
            .output();
      });
    }

    connector.subscribe();

    if (!hasConnector) {
      _channelConnectors[channel] = connector;
    }
  }

  /// Check if reconnect to channels is required
  void _connectChannels() {
    // Stop if any channel added
    if (_channels.isEmpty) {
      return;
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
    configs.echoOptions.onChangeState?.call(.closed);
    client.disconnect();
    client.dispose();
  }
}
