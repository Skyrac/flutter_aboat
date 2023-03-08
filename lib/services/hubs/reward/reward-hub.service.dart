import 'dart:convert';
import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/rewards/reward.model.dart';
import 'package:Talkaboat/services/hubs/hub-service.dart';
import 'package:Talkaboat/services/user/reward.service.dart';
import 'package:flutter/foundation.dart';

class RewardHubService extends HubService {
  @override
  String get hubName => "reward";

  RewardHubService() : super();

  final RewardService rewardService = getIt<RewardService>();

  @override
  connect() async {
    connection.on("RewardUpdate", updateAndValidateReward);
    await super.connect();
  }

  void updateAndValidateReward(List<Object?>? arguments) {
    if (arguments != null && arguments[0] != null) {
      var value = arguments[0];
      var reward = Reward.fromJson(jsonDecode(jsonEncode(value)));
      rewardService.Update(reward);
    }
  }

  dynamic createRequestData(dynamic owner, int asset, int playTime) {
    return {"owner": owner.toString(), "asset": asset, "playTime": playTime};
  }

  Future<void> Play(int owner, int asset, int playTime) async {
    if (!await checkConnection()) {
      return;
    }
    try {
      var data = createRequestData(owner, asset, playTime);

      debugPrint("$data sending heartbeat for $owner episode $asset");
      var result = await connection.invoke("Play", args: <Object>[data]);
      debugPrint("Play $result");
    } catch (e) {
      debugPrint("Play $e");
    }
  }

  Future<void> PlayLiveStream(String guid) async {
    if (!await checkConnection()) {
      return;
    }
    try {
      var result = await connection.invoke("Play", args: <Object>[
        {
          "Owner": guid,
          "Type": 1,
        }
      ]);
      debugPrint("PlayLiveStream $result");
    } catch (e) {
      debugPrint("PlayLiveStream $e");
    }
  }

  Future<void> Pause(int owner, int asset, int playTime) async {
    if (!await checkConnection()) {
      return;
    }
    try {
      var data = createRequestData(owner, asset, playTime);
      await connection.invoke("Pause", args: <Object>[data]);
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> Stop(int owner, int asset, int playTime) async {
    if (!await checkConnection()) {
      return;
    }
    try {
      var data = createRequestData(owner, asset, playTime);
      await connection.invoke("Stop", args: <Object>[data]);
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> StopLiveStream(String guid) async {
    if (!await checkConnection()) {
      return;
    }
    try {
      var result = await connection.invoke("Stop", args: <Object>[
        {
          "Owner": guid,
          "Type": 1,
        }
      ]);
      debugPrint("StopLiveStream $result");
    } catch (e) {
      debugPrint("StopLiveStream $e");
    }
  }

  Future<void> Mute(int owner, int asset, int playTime) async {
    if (!await checkConnection()) {
      return;
    }
    try {
      var data = createRequestData(owner, asset, playTime);
      await connection.invoke("Mute", args: <Object>[data]);
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> MuteLiveStream(String guid) async {
    if (!await checkConnection()) {
      return;
    }
    try {
      var result = await connection.invoke("Mute", args: <Object>[
        {
          "Owner": guid,
          "Type": 1,
        }
      ]);
      debugPrint("MuteLiveStream $result");
    } catch (e) {
      debugPrint("MuteLiveStream $e");
    }
  }

  Future<void> Unmute(int owner, int asset, int playTime) async {
    if (!await checkConnection()) {
      return;
    }
    try {
      var data = createRequestData(owner, asset, playTime);
      await connection.invoke("Unmute", args: <Object>[data]);
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> UnmuteLiveStream(String guid) async {
    if (!await checkConnection()) {
      return;
    }
    try {
      var result = await connection.invoke("Unmute", args: <Object>[
        {
          "Owner": guid,
          "Type": 1,
        }
      ]);
      debugPrint("UnmuteLiveStream $result");
    } catch (e) {
      debugPrint("UnmuteLiveStream $e");
    }
  }

  Future<void> Heartbeat(int owner, int asset, int playTime) async {
    if (!await checkConnection()) {
      return;
    }
    try {
      var data = createRequestData(owner, asset, playTime);

      debugPrint("$data sending heartbeat for $owner episode $asset");
      await connection.invoke("Heartbeat", args: <Object>[data]);
    } catch (e) {
      debugPrint("Heartbeat Error $e");
    }
  }

  Future<void> HeartbeatLiveStream(String guid) async {
    if (!await checkConnection()) {
      return;
    }
    try {
      var result = await connection.invoke("Heartbeat", args: <Object>[
        {
          "Owner": guid,
          "Type": 1,
        }
      ]);
      debugPrint("HeartbeatLiveStream $result");
    } catch (e) {
      debugPrint("HeartbeatLiveStream $e");
    }
  }
}
