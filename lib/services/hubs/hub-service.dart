import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/services/device/connection-state.service.dart';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:logging/logging.dart';

import '../user/user.service.dart';

abstract class HubService {
  final isProduction = const String.fromEnvironment('IS_PRODUCTION') == '1';
  final useTestServer = false;
  final userService = getIt<UserService>();
  final connectionStateService = getIt<ConnectionStateService>();
  final testServerUrl = "http://192.168.10.177:5000/hubs/";
  final serverUrl = "http://api.talkaboat.online/hubs/";
  late final HttpConnectionOptions options;
  late final HubConnection connection;
  final hubName = "";

  HubService() {
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen((LogRecord rec) {
      debugPrint('${rec.level.name}: ${rec.time}: $hubName: ${rec.message}');
    });

    final hubProtLogger = Logger("SignalR - hub");
    // If you want to also to log out transport messages:
    final transportProtLogger = Logger("SignalR - transport");

    options = HttpConnectionOptions(
        accessTokenFactory: () async => Future.value(userService.token),
        requestTimeout: 15000,
        logger: transportProtLogger,
        transport: HttpTransportType.WebSockets,
        skipNegotiation: true,
        logMessageContent: false);
    connection = HubConnectionBuilder()
        .withUrl((useTestServer && !isProduction ? testServerUrl : serverUrl) + hubName, options: options)
        .withAutomaticReconnect(retryDelays: [0, 1000, 2000, 4000, 8000, 16000, 32000])
        .configureLogging(hubProtLogger)
        .build();
  }

  connect() async {
    try {
      await connection.start();
    } catch (e) {

    }
  }

  disconnect() async {
    await connection.stop();
  }

  Future<bool> checkConnection() async {
    if (!userService.isConnected || !connectionStateService.isConnected) {
      return false;
    }
    var state = connection.state;
    debugPrint("$state");
    if (state != HubConnectionState.Connected) {
      if (state != HubConnectionState.Connecting && state != HubConnectionState.Reconnecting) {
        await connect();
        return checkConnection();
      }
      return false;
    }
    return true;
  }

  bool get isConnected =>
      connection.state == HubConnectionState.Connected ||
      connection.state == HubConnectionState.Connecting ||
      connection.state == HubConnectionState.Reconnecting;
}
