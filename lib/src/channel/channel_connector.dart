import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:pipen_echo/src/channel/laravel_private_channel.dart';
import 'package:pipen_echo/src/extension/string_output_extension.dart';
import 'package:pipen_echo/src/pusher/pusher_echo_options.dart';
import 'package:pipen_echo/src/pusher/pusher_service.dart';

class ChannelConnector {
  final LaravelPrivateChannel _channel;
  PusherChannelsClient client;
  PusherEchoOptions options;
  PrivateChannel? channel;

  ChannelConnector({
    required this.client,
    required this.options,
    required LaravelPrivateChannel channel,
  }) : _channel = channel;

  /// Connect to channel
  Future<void> connect() async {
    options.onConnecting?.call().output();
    client.onConnectionEstablished.listen((_) {
      options.onConnectionEstablished?.call().output();
      _connectChannel();
    });
    client.pusherErrorEventStream.listen((_) {});

    await client.connect();
  }

  void _connectChannel() {
    channel = client.privateChannel(
      _channel.channelName,
      authorizationDelegate: pusher.authorizationDelegate,
    );

    channel!.whenSubscriptionSucceeded().listen((data) {
      options.onChannelConnected?.call(data.channelName).output();
    });
    channel!.onSubscriptionError().listen((data) {
      options.onSubscriptionError?.call(data.channelName).output();
    });
    channel!.onAuthenticationSubscriptionFailed().listen((data) {
      options.onAuthenticationSubscriptionFailed?.call(data.channelName).output();
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
    client.disconnect();
    client.dispose();
  }
}
