import 'dart:convert';
import 'package:pipen_echo/pipen_echo.dart';
import 'package:pipen_echo/src/config/type_defs.dart';

class ChannelEvent {
  ChannelEvent({
    required this._channelName,
    required this.eventName,
    this._onData,
  }) : channelName = 'private-$_channelName';

  final String eventName, channelName, _channelName;
  final OnJson? _onData;

  ChannelEvent copy({String? channelName, String? eventName, OnJson? onData}) {
    return .new(
      eventName: eventName ?? this.eventName,
      channelName: channelName ?? _channelName,
      onData: onData ?? _onData,
    );
  }

  PusherPrivateChannel toChannel() =>
      PusherPrivateChannel(channelName: _channelName);

  void onData(String data) {
    try {
      final json = jsonDecode(data);
      _onData?.call(json);
    } catch (e) {
      print(e);
    }
  }
}
