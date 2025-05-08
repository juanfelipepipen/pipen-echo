import 'package:pipen_echo/src/options/pusher_echo_options.dart';
import 'package:pipen_echo/src/channel/channel_connector.dart';
import 'package:pipen_echo/src/channel/laravel_private_channel.dart';
import 'package:pipen_echo/src/pusher/pusher_service.dart';

extension ChannelExtension on LaravelPrivateChannel {
  /// Connect to channel
  Future<ChannelConnector> connect({PusherEchoOptions? options}) async {
    final connector = ChannelConnector(
      channel: this,
      client: pusher.client(),
      options: options ?? pusher.echoOptions,
    );
    await connector.connect();
    return connector;
  }
}
