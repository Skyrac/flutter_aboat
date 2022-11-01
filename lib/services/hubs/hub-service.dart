import 'package:Talkaboat/injection/injector.dart';
import 'package:signalr_netcore/signalr_client.dart';

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
    options = HttpConnectionOptions(accessTokenFactory: () async => Future.value(userService.token));
    connection = HubConnectionBuilder()
        .withUrl((useTestServer && !isProduction ? testServerUrl : serverUrl) + hubName, options: options)
        .withAutomaticReconnect(retryDelays: [2000, 5000, 10000, 20000]).build();
  }

  connect() async {
    await connection.start();
    print("Connected to ${hubName}-hub");
  }

  disconnect() async {
    await connection.stop();
  }

  Future<bool> checkConnection() async {
    if (!userService.isConnected) {
      return false;
    }
    var state = connection.state;
    if (state != HubConnectionState.Connected) {
      if (state != HubConnectionState.Connecting && state != HubConnectionState.Reconnecting) {
        await connect();
      }
      return false;
    }
    return true;
  }
}
