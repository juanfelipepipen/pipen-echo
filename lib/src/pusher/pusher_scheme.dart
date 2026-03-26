enum PusherScheme {
  ws,
  wss;

  /// Get scheme from string
  static PusherScheme fromString(String value) {
    return value == 'ws' ? ws : wss;
  }
}
