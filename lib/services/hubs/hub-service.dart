import 'package:Talkaboat/injection/injector.dart';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:logging/logging.dart';

import '../user/user.service.dart';

abstract class HubService {
  final isProduction = const String.fromEnvironment('IS_PRODUCTION') == '1';
  final useTestServer = false;
  final userService = getIt<UserService>();
  final testServerUrl = "http://192.168.10.177:5000/hubs/";
  final serverUrl = "https://api.talkaboat.online/hubs/";
  late final HttpConnectionOptions options;
  late final HubConnection connection;
  final hubName = "";

  HubService() {
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen((LogRecord rec) {
      debugPrint('${rec.level.name}: $hubName ${rec.time}: ${rec.message}');
    });

    final hubProtLogger = Logger("SignalR - hub");
    // If you want to also to log out transport messages:
    final transportProtLogger = Logger("SignalR - transport");

    options = HttpConnectionOptions(
        accessTokenFactory: () async => Future.value(userService.token),
        requestTimeout: 15000,
        logger: transportProtLogger,
        logMessageContent: true,
        transport: HttpTransportType.ServerSentEvents);
    connection = HubConnectionBuilder()
        .withUrl((useTestServer && !isProduction ? testServerUrl : serverUrl) + hubName, options: options)
        .withAutomaticReconnect(retryDelays: [0, 1000, 2000, 4000, 8000, 16000, 32000])
        .configureLogging(hubProtLogger)
        .build();
  }

  connect() async {
    try {
      debugPrint("current state ${connection.state}");
      await connection.start();
      debugPrint("Connected to $hubName-hub");
      return true;
    } catch (e) {
      debugPrint("$e");
      return null;
    }
  }

  disconnect() async {
    await connection.stop();
  }

  Future<bool> checkConnection() async {
    if (!userService.isConnected) {
      debugPrint("myError: not connected $hubName");
      return false;
    }
    var state = connection.state;
    if (state != HubConnectionState.Connected) {
      if (state != HubConnectionState.Connecting && state != HubConnectionState.Reconnecting) {
        debugPrint("myError: reconnecting $hubName");
        final result = await connect();
        debugPrint("myError: reconnect result $result");
        if (result != null) {
          return true;
        }
      }
      debugPrint("myError: not connected $state");
      return false;
    }
    return true;
  }

  bool get isConnected =>
      connection.state == HubConnectionState.Connected ||
      connection.state == HubConnectionState.Connecting ||
      connection.state == HubConnectionState.Reconnecting;
}
