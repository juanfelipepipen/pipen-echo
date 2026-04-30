enum WebSocketScheme {
  ws,
  wss;

  /// Get scheme from string
  static WebSocketScheme fromString(String value) {
    return value == 'ws' ? ws : wss;
  }
}
