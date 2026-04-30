import 'package:pipen_echo/pipen_echo.dart';

class BroadcastBuilder {
  BroadcastBuilder._({required this._config});

  final BroadcastConfig _config;

  factory BroadcastBuilder({
    required PusherClientEnv env,
    required PusherEchoOptions echoOptions,
  }) {
    final authUrl = '$env.apiUrl/api/broadcasting/auth';
    return BroadcastBuilder._(
      config: .new(
        env: env,
        authUrl: authUrl,
        echoOptions: echoOptions,
        authorizationDelegate: .forPrivateChannel(
          authorizationEndpoint: .parse(authUrl),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $env.accessToken',
          },
        ),
      ),
    );
  }

  BroadcastConnection toConnection() => .new(
    configs: _config,
    client: .websocket(
      options: .fromHost(
        key: _config.env.reverbKey,
        host: _config.env.reverbHost,
        port: _config.env.reverbPort,
        metadata: .byDefault(),
        shouldSupplyMetadataQueries: true,
        scheme: switch (_config.env.reverbScheme) {
          .ws => 'ws',
          .wss => 'wss',
        },
      ),
      connectionErrorHandler: (exception, trace, refresh) {
        print('ERROR ON PUSHER');
        print(exception);
        _config.echoOptions.onChangeState?.call(.reconnecting);
        // if (exception is SocketException) {
        _config.echoOptions.outputs?.onConnectionFail?.call().output();
        Future.delayed(_config.echoOptions.refreshWait, () => refresh());
        // }
      },
    ),
  );
}
