enum ChannelType { private, public }

class ChannelSubscription {
  ChannelSubscription({required this.channelName, required this.type});

  ChannelSubscription.private({required this.channelName}) : type = .private;

  ChannelSubscription.public({required this.channelName}) : type = .public;

  final ChannelType type;
  final String channelName;
}
