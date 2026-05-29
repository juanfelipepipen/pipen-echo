import 'dart:async';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:pipen_echo/pipen_echo.dart';

typedef EventListenerStream = StreamSubscription<ChannelReadEvent>;
typedef EventListener = ({ChannelEvent event, EventListenerStream listener});
typedef ChannelConnectors = Map<BroadcastChannel, PrivateChannel>;
typedef ChannelEventListeners = Map<BroadcastChannel, List<EventListener>>;

class BroadcastConnection {
  BroadcastConnection({required this.client, required this.configs});

  /// Pusher client
  final PusherChannelsClient client;

  /// Pusher client configs
  final BroadcastConfig configs;

  /// Map of channel info and her current connection to pusher
  final ChannelConnectors _channels = {};

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
  void subscribe(BroadcastChannel channel) {
    final exists = _channels.keys.contains(channel);

    if (!exists) {
      if (channel is BroadcastChannelPrivate) {
        final connector = _connectPrivateChannel(channel);
        _bindChannelEvents(channel, connector);
      }
    }
  }

  /// Bind channel events
  void attach(ChannelEventAttach attach) {
    final connector = _channels[attach.channel];
    if (connector != null) {
      _bind(attach.channel, attach, connector);
    }
  }

  /// Unattach event listener
  void unattach(ChannelEvent targetEvent) {
    for (final eventListener in _eventListeners.values) {
      eventListener.removeWhere((listener) => listener.event == targetEvent);
    }
  }

  /// Connect to pusher channel
  PrivateChannel _connectPrivateChannel(BroadcastChannelPrivate channel) {
    print('Echo - Connecting to channel: [${channel.channelName}]');

    final connector = client.privateChannel(
      channel.channelName,
      authorizationDelegate: configs.authorizationDelegate,
    );

    connector.whenSubscriptionSucceeded().listen((data) {
      print('Echo - Success connection to channel: [${channel.channelName}]');
      configs.echoOptions.onChangeState?.call(.connected);
      configs.echoOptions.outputs?.onChannelConnected
          ?.call(data.channelName)
          .output();
    });

    connector.onSubscriptionError().listen((data) {
      print('Subscription channel ERROR');
      print(data.channelName);
      print(data.data);

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

    connector.subscribe();
    _channels[channel] = connector;
    return connector;
  }

  /// Bind all channel events
  void _bindChannelEvents(BroadcastChannel channel, PrivateChannel connector) {
    for (final event in channel.events) {
      _bind(channel, event, connector);
    }
  }

  /// Bind channel event listener
  void _bind(
    BroadcastChannel channel,
    ChannelEvent event,
    PrivateChannel connector,
  ) {
    final listener = connector.bind(event.eventName).listen((data) {
      event.onData(data.data.toString());
    });
    _eventListeners[channel]?.add((event: event, listener: listener));
  }

  /// Check if reconnect to channels is required
  void _connectChannels() {
    // // Stop if any channel added
    // if (LL_channels.isEmpty) {
    //   return;
    // }
    //
    // // Connect to channels
    // for (final channel in LL_channels) {
    //   _connectPrivateChannel(channel);
    // }
    //
    // // Bind events
    // for (final channel in LL_channels) {
    //   for (final event in channel.events) {
    //     attach(event);
    //   }
    // }
  }

  /// Close channel
  void close() {
    configs.echoOptions.onChangeState?.call(.closed);
    client.disconnect();
    client.dispose();
  }
}
