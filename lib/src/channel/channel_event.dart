import 'dart:convert';
import 'package:pipen_echo/pipen_echo.dart';
import 'package:pipen_echo/src/config/type_defs.dart';

class ChannelEvent {
  ChannelEvent({required this.eventName, required OnJson onEvent})
    : _onEvent = onEvent;

  ChannelEvent copy({required OnJson onEvent}) {
    return .new(eventName: eventName, onEvent: onEvent);
  }

  final OnJson _onEvent;
  final String eventName;

  void onData(String data) {
    try {
      JsonMap json = jsonDecode(data);
      _onEvent.call(json);
    } catch (e) {
      print(e);
    }
  }
}

class KChannelEvent {
  KChannelEvent({
    required String channelName,
    required this.eventName,
    required OnJson onEvent,
  }) : _onEvent = onEvent,
       channelName = 'private-' + channelName,
       _channelName = channelName;

  final OnJson _onEvent;
  final String eventName;
  final String channelName, _channelName;

  ChannelEvent copy({required OnJson onEvent}) {
    return .new(eventName: eventName, onEvent: onEvent);
  }

  PusherPrivateChannel toChannel() =>
      PusherPrivateChannel(channelName: _channelName);

  void onData(String data) {
    try {
      JsonMap json = jsonDecode(data);
      _onEvent.call(json);
    } catch (e) {
      print(e);
    }
  }
}
