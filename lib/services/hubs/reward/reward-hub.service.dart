import 'dart:convert';

import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/rewards/reward.model.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:signalr_netcore/signalr_client.dart';

class RewardHubService {
  static final userService = getIt<UserService>();
  static final serverUrl = "https://api.talkaboat.online/hubs/reward";
  static final options = HttpConnectionOptions(accessTokenFactory: () async => Future.value(userService.token));
  static final connection = HubConnectionBuilder()
      .withUrl(serverUrl, options: options)
      .withAutomaticReconnect(retryDelays: [2000, 5000, 10000, 20000])
      .build();

  static connect() async {
    connection.on("RewardUpdate", updateAndValidateReward);
    await connection.start()?.then((value) => print("Connected to reward hub"));
  }

  static void updateAndValidateReward(List<Object?>? arguments) {
    if(arguments != null && arguments[0] != null) {
      var value = arguments[0];
      var reward = Reward.fromJson(jsonDecode(jsonEncode(value)));
      userService.updateRewards(reward);
    }
  }


  static dynamic createRequestData(int owner, int asset, int playTime) {
    return {"Owner": owner, "Asset": asset, "PlayTime": playTime};
  }

  static Future<void> Play(int owner, int asset, int playTime) async {
    if (!userService.isConnected) {
      return;
    }
    var state = connection.state;
    if(state != HubConnectionState.Connected) {
      if(state != HubConnectionState.Connecting && state != HubConnectionState.Reconnecting) {
        await connect();
      }
      return;
    }
    var data = createRequestData(owner, asset, playTime);
    await connection.invoke("Play", args: <Object>[data]);
  }

  static Future<void> Pause(int owner, int asset, int playTime) async {
    if (!userService.isConnected) {
      return;
    }
    var state = connection.state;
    if(state != HubConnectionState.Connected) {
      if(state != HubConnectionState.Connecting && state != HubConnectionState.Reconnecting) {
        await connect();
      }
      return;
    }
    var data = createRequestData(owner, asset, playTime);
    await connection.invoke("Pause", args: <Object>[data]);
  }

  static Future<void> Stop(int owner, int asset, int playTime) async {
    if (!userService.isConnected) {
      return;
    }
    var state = connection.state;
    if(state != HubConnectionState.Connected) {
      if(state != HubConnectionState.Connecting && state != HubConnectionState.Reconnecting) {
        await connect();
      }
      return;
    }
    var data = createRequestData(owner, asset, playTime);
    await connection.invoke("Stop", args: <Object>[data]);
  }

  static Future<void> Mute(int owner, int asset, int playTime) async {
    if (!userService.isConnected) {
      return;
    }
    var state = connection.state;
    if(state != HubConnectionState.Connected) {
      if(state != HubConnectionState.Connecting && state != HubConnectionState.Reconnecting) {
        await connect();
      }
      return;
    }
    var data = createRequestData(owner, asset, playTime);
    await connection.invoke("Mute", args: <Object>[data]);
  }

  static Future<void> Unmute(int owner, int asset, int playTime) async {
    if (!userService.isConnected) {
      return;
    }
    var state = connection.state;
    if(state != HubConnectionState.Connected) {
      if(state != HubConnectionState.Connecting && state != HubConnectionState.Reconnecting) {
        await connect();
      }
      return;
    }
    var data = createRequestData(owner, asset, playTime);
    await connection.invoke("Unmute", args: <Object>[data]);
  }

  static Future<void> Heartbeat(int owner, int asset, int playTime) async {
    if (!userService.isConnected) {
      return;
    }
    var state = connection.state;
    if(state != HubConnectionState.Connected) {
      if(state != HubConnectionState.Connecting && state != HubConnectionState.Reconnecting) {
        await connect();
      }
      return;
    }
    var data = createRequestData(owner, asset, playTime);
    await connection.invoke("Heartbeat", args: <Object>[data]);
  }
}