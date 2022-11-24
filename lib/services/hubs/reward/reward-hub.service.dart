import 'dart:convert';
import 'package:Talkaboat/models/rewards/reward.model.dart';
import 'package:Talkaboat/services/hubs/hub-service.dart';

class RewardHubService extends HubService {
  @override
  String get hubName => "reward";

  RewardHubService() : super() {}

  @override
  connect() async {
    connection.on("RewardUpdate", updateAndValidateReward);
    await super.connect();
  }

  void updateAndValidateReward(List<Object?>? arguments) {
    if (arguments != null && arguments[0] != null) {
      var value = arguments[0];
      var reward = Reward.fromJson(jsonDecode(jsonEncode(value)));
      userService.updateRewards(reward);
    }
  }

  dynamic createRequestData(int owner, int asset, int playTime) {
    return {"Owner": owner, "Asset": asset, "PlayTime": playTime};
  }

  Future<void> Play(int owner, int asset, int playTime) async {
    if (!await checkConnection()) {
      return;
    }
    var data = createRequestData(owner, asset, playTime);
    await connection.invoke("Play", args: <Object>[data]);
  }

  Future<void> Pause(int owner, int asset, int playTime) async {
    if (!await checkConnection()) {
      return;
    }
    var data = createRequestData(owner, asset, playTime);
    await connection.invoke("Pause", args: <Object>[data]);
  }

  Future<void> Stop(int owner, int asset, int playTime) async {
    if (!await checkConnection()) {
      return;
    }
    var data = createRequestData(owner, asset, playTime);
    await connection.invoke("Stop", args: <Object>[data]);
  }

  Future<void> Mute(int owner, int asset, int playTime) async {
    if (!await checkConnection()) {
      return;
    }
    var data = createRequestData(owner, asset, playTime);
    await connection.invoke("Mute", args: <Object>[data]);
  }

  Future<void> Unmute(int owner, int asset, int playTime) async {
    if (!await checkConnection()) {
      return;
    }
    var data = createRequestData(owner, asset, playTime);
    await connection.invoke("Unmute", args: <Object>[data]);
  }

  Future<void> Heartbeat(int owner, int asset, int playTime) async {
    try {
      if (!await checkConnection()) {
        return;
      }
      var data = createRequestData(owner, asset, playTime);
      await connection.invoke("Heartbeat", args: <Object>[data]);
    } catch (e) {
      print(e);
    }
  }
}
