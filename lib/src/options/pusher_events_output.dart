class PusherEventsOutput {
  PusherEventsOutput({
    this.onConnectionFail,
    this.onChannelConnected,
    this.onConnectionEstablished,
    this.onConnecting,
    this.onAuthenticationSubscriptionFailed,
    this.onSubscriptionError,
  });

  String Function()? onConnectionFail, onConnectionEstablished, onConnecting;
  String Function(String channelName)? onChannelConnected,
      onAuthenticationSubscriptionFailed,
      onSubscriptionError;
}
