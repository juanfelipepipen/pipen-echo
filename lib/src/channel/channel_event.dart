import 'dart:convert';
import 'package:pipen_echo/pipen_echo.dart';
import 'package:pipen_echo/src/config/type_defs.dart';

typedef ChannelEventList = List<ChannelEvent>;

class ChannelEvent {
  ChannelEvent({required this.eventName, this._onData});

  final String eventName;
  final OnJson? _onData;

  ChannelEvent copy({String? channelName, String? eventName, OnJson? onData}) {
    return .new(
      eventName: eventName ?? this.eventName,
      onData: onData ?? _onData,
    );
  }

  void onData(String data) {
    try {
      final json = jsonDecode(data);
      _onData?.call(json);
    } catch (e) {
      print(e);
    }
  }
}

/// Attach a channel event to a broadcast channel
class ChannelEventAttach extends ChannelEvent {
  ChannelEventAttach({
    required super.onData,
    required super.eventName,
    required this.channel,
  });

  final BroadcastChannel channel;
}
