import 'dart:convert';
import 'package:pipen_echo/src/config/type_defs.dart';

class ChannelEvent {
  ChannelEvent({required this.eventName, required OnJson onEvent}) : _onEvent = onEvent;

  ChannelEvent copy({required OnJson onEvent}) =>
      ChannelEvent(eventName: eventName, onEvent: onEvent);

  final OnJson _onEvent;
  final String eventName;

  void onData(String data) {
    try {
      JsonMap json = jsonDecode(data);
      _onEvent.call(json);
    } catch (_) {}
  }
}
