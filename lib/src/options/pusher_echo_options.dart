import 'package:pipen_echo/src/options/pusher_events_output.dart';

enum ConnectionState { connected, connecting, reconnecting, closed }

class PusherEchoOptions {
  PusherEchoOptions({Duration? refreshWait, this.outputs, this.onChangeState})
    : refreshWait = refreshWait ?? Duration(seconds: 10);

  Function(ConnectionState)? onChangeState;
  PusherEventsOutput? outputs;
  Duration refreshWait;
}
