import 'package:pipen_echo/src/options/pusher_events_output.dart';

enum ChannelConnectionState { connected, connecting, reconnecting, closed }

class PusherEchoOptions {
  PusherEchoOptions({Duration? refreshWait, this.outputs, this.onChangeState})
    : refreshWait = refreshWait ?? .new(seconds: 10);

  /// Listen state changes on pusher connection
  final Function(ChannelConnectionState)? onChangeState;

  /// Custom printers for pusher connection errors/alerts
  final PusherEventsOutput? outputs;

  /// Delay time for retry connection (default 10 seconds)
  final Duration refreshWait;
}
