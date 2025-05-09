import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:pipen_echo/src/extension/string_output_extension.dart';
import 'package:pipen_echo/src/options/pusher_echo_options.dart';

late PusherService pusher;

class PusherService {
  String apiUrl, accessToken, reverbKey, reverbHost;
  PusherEchoOptions echoOptions;
  int? reverbPort;

  PusherService({
    this.reverbPort,
    required this.apiUrl,
    required this.reverbHost,
    required this.reverbKey,
    required this.accessToken,
    required this.echoOptions,
  });

  /// Auth URL for authenticate pusher connections
  String get authUrl => '$apiUrl/api/broadcasting/auth';

  /// Authorization delegation for private channels
  EndpointAuthorizableChannelTokenAuthorizationDelegate<PrivateChannelAuthorizationData>
  get authorizationDelegate =>
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: Uri.parse(pusher.authUrl),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $accessToken'},
      );

  /// Authorization delegation for private channels
  EndpointAuthorizableChannelTokenAuthorizationDelegate<PresenceChannelAuthorizationData>
  get authorizationPresence =>
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPresenceChannel(
        authorizationEndpoint: Uri.parse(pusher.authUrl),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $accessToken'},
      );

  /// Pusher client options
  PusherChannelsOptions options() => PusherChannelsOptions.fromHost(
    scheme: 'ws',
    key: reverbKey,
    host: reverbHost,
    port: reverbPort,
    shouldSupplyMetadataQueries: true,
    metadata: PusherChannelsOptionsMetadata.byDefault(),
  );

  /// Pusher client
  PusherChannelsClient client() => PusherChannelsClient.websocket(
    options: options(),
    connectionErrorHandler: (exception, trace, refresh) {
      print(exception);
      echoOptions.onChangeState?.call(ChannelConnectionState.reconnecting);
      // if (exception is SocketException) {
      echoOptions.outputs?.onConnectionFail?.call().output();
      Future.delayed(echoOptions.refreshWait, () => refresh());
      // }
    },
  );
}
