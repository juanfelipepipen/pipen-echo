import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:pipen_echo/src/channel/laravel_private_channel.dart';
import 'package:pipen_echo/src/extension/string_output_extension.dart';
import 'package:pipen_echo/src/options/pusher_echo_options.dart';
import 'package:pipen_echo/src/pusher/pusher_service.dart';

class ChannelConnector {
  final LaravelPrivateChannel _channel;
  PusherChannelsClient client;
  PusherEchoOptions options;
  PrivateChannel? channel;

  /// [Constructor]
  ChannelConnector({
    required this.client,
    required this.options,
    required LaravelPrivateChannel channel,
  }) : _channel = channel;

  /// Connect to channel
  Future<void> connect() async {
    options.onChangeState?.call(ConnectionState.connecting);
    options.outputs?.onConnecting?.call().output();
    client.onConnectionEstablished.listen((_) {
      options.outputs?.onConnectionEstablished?.call().output();
      _connectChannel();
    });
    client.pusherErrorEventStream.listen((_) {});

    await client.connect();
  }

  /// Connect to pusher channel
  void _connectChannel() {
    channel = client.privateChannel(
      _channel.channelName,
      authorizationDelegate: pusher.authorizationDelegate,
    );

    channel!.whenSubscriptionSucceeded().listen((data) {
      options.onChangeState?.call(ConnectionState.connected);
      options.outputs?.onChannelConnected?.call(data.channelName).output();
    });

    channel!.onSubscriptionError().listen((data) {
      options.onChangeState?.call(ConnectionState.reconnecting);
      options.outputs?.onSubscriptionError?.call(data.channelName).output();
    });

    channel!.onAuthenticationSubscriptionFailed().listen((data) {
      options.onChangeState?.call(ConnectionState.reconnecting);
      options.outputs?.onAuthenticationSubscriptionFailed?.call(data.channelName).output();
    });

    channel!.subscribe();

    _bindEvents();
  }

  /// Bind channel events
  void _bindEvents() {
    if (channel case PrivateChannel channel) {
      for (final event in _channel.events) {
        channel.bind(event.eventName).listen((data) {
          event.onData(data.data.toString());
        });
      }
    }
  }

  /// Close channel
  void close() {
    options.onChangeState?.call(ConnectionState.closed);
    client.disconnect();
    client.dispose();
  }
}
