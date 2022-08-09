import 'dart:convert';

import 'package:dio/dio.dart';

import '../../configuration/dio.config.dart';
import '../../models/response.model.dart';
import '../../models/rewards/reward.model.dart';
import '../../models/user/user-info.model.dart';

class UserRepository {
  UserRepository._();

  static Future<bool> requestEmailLogin(String email) async {
    try {
      var response = await Dio().post<String>(
          'https://api.talkaboat.online/v1/user/login/email/$email');
      var convertedData = response.data;
      return convertedData != null;
    } catch (e) {
      print(e);
    }
    return false;
  }

  static Future<String> emailLogin(String email, String pin) async {
    try {
      var response = await Dio().post<String>(
          'https://api.talkaboat.online/v1/user/login/email',
          data: {"address": email, "signature": pin});
      var convertedData = json.decode(response.data!)["token"];
      return convertedData;
    } catch (exception) {
      return "";
    }
  }

  static Future<UserInfoData> getUserInfo() async {
    try {
      var response = await dio.get<String>('/v1/user/profile');
      var convertedData = UserInfoData.fromJson(json.decode(response.data!));
      return convertedData;
    } catch (exception) {
      return UserInfoData();
    }
  }

  static Future<Reward> getUserRewards() async {
    try {
      var response = await dio.get<String>('/v1/user/reward');
      var convertedData = Reward.fromJson(json.decode(response.data!));
      return convertedData;
    } catch (exception) {
      return Reward();
    }
  }

  static Future<List<UserInfoData>> getFriends(int amount, int offset) async {
    try {
      var response = await dio.get<String>('/v1/social/friends/$amount/$offset');
      var convertedData = jsonDecode(response.data!)
          .map((data) => UserInfoData.fromJson(data))
          .toList();
      return convertedData;
    } catch (exception) {
      return List.empty();
    }
  }

  static Future<List<UserInfoData>> getUserFriends(int userId, int amount, int offset) async {
    try {
      var response = await dio.get<String>('/v1/social/friends/$userId/$amount/$offset');
      var convertedData = jsonDecode(response.data!)
          .map((data) => UserInfoData.fromJson(data))
          .toList();
      return convertedData;
    } catch (exception) {
      return List.empty();
    }
  }

  static Future<ResponseModel> firebaseLogin(String userIdToken) async {
    var data = ResponseModel(status: 0, text: userIdToken);
    var response =
        await dio.post<String>('/v1/user/login/firebase', data: data);
    var convertedData = ResponseModel.fromJson(json.decode(response.data!));
    return convertedData;
  }

  static Future<ResponseModel> firebaseVerify(
      String userIdToken, String pin) async {
    try {
      var data = ResponseModel(status: 0, text: userIdToken);
      var response =
          await dio.post<String>('/v1/user/login/firebase/$pin', data: data);
      var convertedData = ResponseModel.fromJson(json.decode(response.data!));
      return convertedData;
    } catch (exception) {
      return ResponseModel();
    }
  }

  static Future<ResponseModel> firebaseRegister(
      String userIdToken, String username, bool newsletter) async {
    try {
      var response =
          await dio.post<String>('/v1/user/register/firebase/', data: {
        "Address": "Social: $username",
        "Signature": userIdToken,
        "UserName": username,
        "Newsletter": newsletter
      });
      var convertedData = ResponseModel.fromJson(json.decode(response.data!));
      return convertedData;
    } catch (exception) {
      return ResponseModel();
    }
  }

  static Future<bool> deleteAccount() async {
    var response = await dio.delete<String>('/v1/user');

    return response.data == null ? false : response.data!.isNotEmpty;
  }

}
