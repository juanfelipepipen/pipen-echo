import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:pipen_echo/src/channel/channel_subscription.dart';
import 'package:pipen_echo/src/channel/laravel_private_channel.dart';
import 'package:pipen_echo/src/extension/string_output_extension.dart';
import 'package:pipen_echo/src/options/pusher_echo_options.dart';
import 'package:pipen_echo/src/pusher/pusher_service.dart';

class ChannelConnectorDynamic {
  ChannelConnectorDynamic({required this.client, required this.options});

  final PusherChannelsClient client;
  final PusherEchoOptions options;
  PrivateChannel? channel;

  List<PusherPrivateChannel> _channels = [];

  /// Connect to channel
  Future<void> connect() async {
    options.onChangeState?.call(.connecting);
    options.outputs?.onConnecting?.call().output();

    // When connection is established subscribe to channels
    client.onConnectionEstablished.listen((_) {
      print('todo ok');
      options.onChangeState?.call(.connected);
      options.outputs?.onConnectionEstablished?.call().output();
      _connectChannel();
    });

    // On connection error
    client.pusherErrorEventStream.listen((e) {
      print(e);
    });

    await client.connect();
  }

  void subscribe(PusherPrivateChannel channel) {
    _channels.add(channel);
  }

  /// Connect to pusher channel
  void _connectChannel() {
    // channel = client.privateChannel(
    //   _channel.channelName,
    //   authorizationDelegate: pusher.authorizationDelegate,
    // );
    //
    // channel!.whenSubscriptionSucceeded().listen((data) {
    //   options.onChangeState?.call(ChannelConnectionState.connected);
    //   options.outputs?.onChannelConnected?.call(data.channelName).output();
    // });
    //
    // channel!.onSubscriptionError().listen((data) {
    //   options.onChangeState?.call(ChannelConnectionState.reconnecting);
    //   options.outputs?.onSubscriptionError?.call(data.channelName).output();
    // });
    //
    // channel!.onAuthenticationSubscriptionFailed().listen((data) {
    //   options.onChangeState?.call(ChannelConnectionState.reconnecting);
    //   options.outputs?.onAuthenticationSubscriptionFailed
    //       ?.call(data.channelName)
    //       .output();
    // });
    //
    // channel!.subscribe();
    //
    // _bindEvents();
  }

  /// Bind channel events
  void _bindEvents() {
    // if (channel case PrivateChannel channel) {
    //   for (final event in _channel.events) {
    //     channel.bind(event.eventName).listen((data) {
    //       event.onData(data.data.toString());
    //     });
    //   }
    // }
  }

  /// Close channel
  void close() {
    options.onChangeState?.call(.closed);
    client.disconnect();
    client.dispose();
  }
}
