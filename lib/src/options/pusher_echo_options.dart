import 'package:pipen_echo/src/options/pusher_events_output.dart';

enum ChannelConnectionState { connected, connecting, reconnecting, closed }

class PusherEchoOptions {
  PusherEchoOptions({Duration? refreshWait, this.outputs, this.onChangeState})
    : refreshWait = refreshWait ?? Duration(seconds: 10);

  Function(ChannelConnectionState)? onChangeState;
  PusherEventsOutput? outputs;
  Duration refreshWait;
}
