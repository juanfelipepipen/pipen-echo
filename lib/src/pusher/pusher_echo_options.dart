class PusherEchoOptions {
  PusherEchoOptions({
    this.onConnectionFail,
    this.onChannelConnected,
    this.onConnectionEstablished,
    this.onConnecting,
    this.onAuthenticationSubscriptionFailed,
    this.onSubscriptionError,
    Duration? refreshWait,
  }) : refreshWait = refreshWait ?? Duration(seconds: 10);

  String Function()? onConnectionFail, onConnectionEstablished, onConnecting;
  String Function(String channelName)? onChannelConnected,
      onAuthenticationSubscriptionFailed,
      onSubscriptionError;
  Duration refreshWait;
}
