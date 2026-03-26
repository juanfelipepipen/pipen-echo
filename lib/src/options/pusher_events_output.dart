class PusherEventsOutput {
  PusherEventsOutput({
    this.onConnectionFail,
    this.onChannelConnected,
    this.onConnectionEstablished,
    this.onConnecting,
    this.onAuthenticationSubscriptionFailed,
    this.onSubscriptionError,
  });

  final String Function()? onConnectionFail, onConnectionEstablished, onConnecting;
  final String Function(String channelName)? onChannelConnected,
      onAuthenticationSubscriptionFailed,
      onSubscriptionError;
}
