import 'dart:convert';

import 'package:Talkaboat/services/user/reward.service.dart';

import '../../configuration/dio.config.dart';
import '../../injection/injector.dart';
import '../../models/rewards/reward.model.dart';
import '../user/user.service.dart';

class TrackingRepository {
  TrackingRepository._();

  static const API = "/v1/media";
  static final userService = getIt<UserService>();
  static final rewardService = getIt<RewardService>();

  static dynamic createRequestData(int owner, int asset, int playTime) {
    return {"Owner": owner, "Asset": asset, "PlayTime": playTime};
  }

  static Future<void> Play(int owner, int asset, int playTime) async {
    if (!userService.isConnected) {
      return;
    }
    var data = createRequestData(owner, asset, playTime);
    var response = await dio.post<String>('$API/play', data: data);
    validateAndUpdate(response);
  }

  static Future<void> Pause(int owner, int asset, int playTime) async {
    if (!userService.isConnected) {
      return;
    }
    var data = createRequestData(owner, asset, playTime);
    var response = await dio.post<String>('$API/pause', data: data);
    validateAndUpdate(response);
  }

  static Future<void> Stop(int owner, int asset, int playTime) async {
    if (!userService.isConnected) {
      return;
    }
    var data = createRequestData(owner, asset, playTime);
    var response = await dio.post<String>('$API/stop', data: data);
    validateAndUpdate(response);
  }

  static validateAndUpdate(response) {
    if (response.data != null && response.data!.isNotEmpty) {
      var convertedData = Reward.fromJson(json.decode(response.data!));
      rewardService.Update(convertedData);
    }
  }

  static Future<void> Mute(int owner, int asset, int playTime) async {
    if (!userService.isConnected) {
      return;
    }
    var data = createRequestData(owner, asset, playTime);
    var response = await dio.post<String>('$API/mute', data: data);
    validateAndUpdate(response);
  }

  static Future<void> Unmute(int owner, int asset, int playTime) async {
    if (!userService.isConnected) {
      return;
    }
    var data = createRequestData(owner, asset, playTime);
    var response = await dio.post<String>('$API/unmute', data: data);
    validateAndUpdate(response);
  }

  static Future<void> Heartbeat(int owner, int asset, int playTime) async {
    if (!userService.isConnected) {
      return;
    }
    var data = createRequestData(owner, asset, playTime);
    var response = await dio.post<String>('$API/heartbeat', data: data);
    validateAndUpdate(response);
  }
}
