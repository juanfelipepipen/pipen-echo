import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:pipen_echo/pipen_echo.dart';

typedef PusherClientEnv = ({
  String apiUrl,
  String accessToken,
  String reverbKey,
  String reverbHost,
  WebSocketScheme reverbScheme,
  int? reverbPort,
});

class BroadcastConfig {
  BroadcastConfig({
    required this.env,
    required this.echoOptions,
    required this.authUrl,
    required this.authorizationDelegate,
  });

  final PusherClientEnv env;
  final PusherEchoOptions echoOptions;

  /// Auth URL for authenticate pusher connections
  final String authUrl;

  /// Authorization delegation for private channels
  final EndpointAuthorizableChannelTokenAuthorizationDelegate<
    PrivateChannelAuthorizationData
  >
  authorizationDelegate;
}
