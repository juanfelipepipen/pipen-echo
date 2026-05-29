import 'package:equatable/equatable.dart';
import 'package:pipen_echo/src/channel/channel_event.dart';

abstract class BroadcastChannel extends Equatable {
  BroadcastChannel({required this.channelName, this.events = const []});

  final List<ChannelEvent> events;
  final String channelName;

  static BroadcastChannelPrivate private({
    required String channelName,
    ChannelEventList events = const [],
  }) => .new(channelName: channelName, events: events);

  static BroadcastChannelPublic public({
    required String channelName,
    ChannelEventList events = const [],
  }) => .new(channelName: channelName, events: events);
}

/// Private channel data
class BroadcastChannelPrivate extends BroadcastChannel {
  BroadcastChannelPrivate({
    required String channelName,
    super.events = const [],
  }) : super(channelName: 'private-$channelName');

  @override
  get props => [channelName];
}

/// Public channel data
class BroadcastChannelPublic extends BroadcastChannel {
  BroadcastChannelPublic({required super.channelName, super.events = const []});

  @override
  get props => [channelName];
}
