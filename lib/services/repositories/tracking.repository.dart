import 'dart:convert';

import 'package:talkaboat/services/user/user.service.dart';

import '../../configuration/dio.config.dart';
import '../../injection/injector.dart';
import '../../models/rewards/reward.model.dart';

class TrackingRepository {
  TrackingRepository._();

  static const API = "/v1/media";
  static final userService = getIt<UserService>();

  static dynamic createRequestData(int owner, int asset, int playTime) {
    return {"Owner": owner, "Asset": asset, "PlayTime": playTime};
  }

  static Future<void> Play(int owner, int asset, int playTime) async {
    if (!userService.isConnected) {
      return;
    }
    var data = createRequestData(owner, asset, playTime);
    var response = await dio.post<String>('$API/play', data: data);
    var convertedData = Reward.fromJson(json.decode(response.data!));
    userService.updateRewards(convertedData);
  }

  static Future<void> Pause(int owner, int asset, int playTime) async {
    if (!userService.isConnected) {
      return;
    }
    var data = createRequestData(owner, asset, playTime);
    var response = await dio.post<String>('$API/pause', data: data);
    var convertedData = Reward.fromJson(json.decode(response.data!));
    userService.updateRewards(convertedData);
  }

  static Future<void> Stop(int owner, int asset, int playTime) async {
    if (!userService.isConnected) {
      return;
    }
    var data = createRequestData(owner, asset, playTime);
    var response = await dio.post<String>('$API/stop', data: data);
    var convertedData = Reward.fromJson(json.decode(response.data!));
    userService.updateRewards(convertedData);
  }

  static Future<void> Mute(int owner, int asset, int playTime) async {
    if (!userService.isConnected) {
      return;
    }
    var data = createRequestData(owner, asset, playTime);
    var response = await dio.post<String>('$API/mute', data: data);
    var convertedData = Reward.fromJson(json.decode(response.data!));
    userService.updateRewards(convertedData);
  }

  static Future<void> Unmute(int owner, int asset, int playTime) async {
    if (!userService.isConnected) {
      return;
    }
    var data = createRequestData(owner, asset, playTime);
    var response = await dio.post<String>('$API/unmute', data: data);
    var convertedData = Reward.fromJson(json.decode(response.data!));
    userService.updateRewards(convertedData);
  }

  static Future<void> Heartbeat(int owner, int asset, int playTime) async {
    if (!userService.isConnected) {
      return;
    }
    var data = createRequestData(owner, asset, playTime);
    var response = await dio.post<String>('$API/heartbeat', data: data);
    var convertedData = Reward.fromJson(json.decode(response.data!));
    userService.updateRewards(convertedData);
  }
}
