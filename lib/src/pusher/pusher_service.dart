import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:pipen_echo/src/extension/string_output_extension.dart';
import 'package:pipen_echo/src/options/pusher_echo_options.dart';
import 'package:pipen_echo/src/pusher/pusher_scheme.dart';

late PusherService pusher;

class PusherService {
  PusherService({
    this.reverbPort,
    required this.apiUrl,
    required this.reverbKey,
    required this.reverbHost,
    required this.accessToken,
    required this.echoOptions,
    required this.reverbScheme,
  });

  final String apiUrl, accessToken, reverbKey, reverbHost;
  final PusherEchoOptions echoOptions;
  final PusherScheme reverbScheme;
  final int? reverbPort;

  /// Auth URL for authenticate pusher connections
  String get authUrl => '$apiUrl/api/broadcasting/auth';

  /// Authorization delegation for private channels
  EndpointAuthorizableChannelTokenAuthorizationDelegate<
    PrivateChannelAuthorizationData
  >
  get authorizationDelegate => .forPrivateChannel(
    authorizationEndpoint: .parse(pusher.authUrl),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
  );

  /// Authorization delegation for private channels
  EndpointAuthorizableChannelTokenAuthorizationDelegate<
    PresenceChannelAuthorizationData
  >
  get authorizationPresence => .forPresenceChannel(
    authorizationEndpoint: .parse(pusher.authUrl),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
  );

  /// Pusher client options
  PusherChannelsOptions options() => .fromHost(
    key: reverbKey,
    host: reverbHost,
    port: reverbPort,
    metadata: .byDefault(),
    shouldSupplyMetadataQueries: true,
    scheme: switch (reverbScheme) {
      .ws => 'ws',
      .wss => 'wss',
    },
  );

  /// Pusher client
  PusherChannelsClient client() => .websocket(
    options: options(),
    connectionErrorHandler: (exception, trace, refresh) {
      print('ERROR ON PUSHER');
      print(exception);
      echoOptions.onChangeState?.call(.reconnecting);
      // if (exception is SocketException) {
      echoOptions.outputs?.onConnectionFail?.call().output();
      Future.delayed(echoOptions.refreshWait, () => refresh());
      // }
    },
  );
}
