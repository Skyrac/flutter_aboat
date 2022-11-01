import 'dart:convert';

import 'package:dio/dio.dart';

import '../../configuration/dio.config.dart';
import '../../models/response.model.dart';
import '../../models/rewards/reward-detail.model.dart';
import '../../models/rewards/reward.model.dart';
import '../../models/user/user-info.model.dart';

class UserRepository {
  UserRepository._();

  static Future<String?> requestEmailLogin(String email) async {
    try {
      var response = await Dio().post<String>('https://api.talkaboat.online/v1/user/login/email/$email');
      var convertedData = response.data;
      print(convertedData);
      return convertedData;
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Future<String> emailLogin(String email, String pin) async {
    try {
      var response = await Dio()
          .post<String>('https://api.talkaboat.online/v1/user/login/email', data: {"address": email, "signature": pin});
      print('data: ${response.data}');
      if (response.data == "Value cannot be null. (Parameter 'User not found! Please register before sign in.')") {
        return "new_account";
      }
      var convertedData = json.decode(response.data!)["token"];
      return convertedData;
    } catch (exception) {
      print(exception);
      final ex = exception as DioError;
      final error = (ex.response?.data ?? "") as String;
      if (error.contains("Value cannot be null. (Parameter 'User not found! Please register before sign in.')")) {
        return "new_account";
      }
      return "";
    }
  }

  static Future<UserInfoData> getUserInfo() async {
    try {
      var response = await dio.get<String>('/v1/user/profile');
      var convertedData = UserInfoData.fromJson(json.decode(response.data!));
      return convertedData;
    } catch (exception) {
      print(exception);
      print((exception as DioError).response!.data);
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

  static Future<List<RewardDetail>> getDetailedUserRewards() async {
    try {
      var response = await dio.get<String>('/v1/user/reward/detail');
      return List<RewardDetail>.from(json.decode(response.data!).map((model) => RewardDetail.fromJson(model)));
    } catch (exception) {
      print(exception);
      return List.empty();
    }
  }

  static Future<List<UserInfoData>> getFriends(int amount, int offset) async {
    try {
      var response = await dio.get<String>('/v1/social/friends/$amount/$offset');
      var convertedData = jsonDecode(response.data!).map((data) => UserInfoData.fromJson(data)).toList();
      return convertedData;
    } catch (exception) {
      return List.empty();
    }
  }

  static Future<List<UserInfoData>> getUserFriends(int userId, int amount, int offset) async {
    try {
      var response = await dio.get<String>('/v1/social/friends/$userId/$amount/$offset');
      var convertedData = jsonDecode(response.data!).map((data) => UserInfoData.fromJson(data)).toList();
      return convertedData;
    } catch (exception) {
      return List.empty();
    }
  }

  static Future<ResponseModel> firebaseLogin(String userIdToken) async {
    var data = ResponseModel(status: 0, text: userIdToken);
    var response = await dio.post<String>('/v1/user/login/firebase', data: data);
    var convertedData = ResponseModel.fromJson(json.decode(response.data!));
    print("firebaseLogin: ${convertedData.toJson()}");
    return convertedData;
  }

  static Future<ResponseModel> firebaseVerify(String userIdToken, String pin) async {
    try {
      var data = ResponseModel(status: 0, text: userIdToken);
      var response = await dio.post<String>('/v1/user/login/firebase/$pin', data: data);
      var convertedData = ResponseModel.fromJson(json.decode(response.data!));
      print(response.data);
      return convertedData;
    } catch (exception) {
      return ResponseModel();
    }
  }

  static Future<ResponseModel> firebaseRegister(String userIdToken, String username, bool newsletter) async {
    try {
      print({"address": "Social: $username", "signature": userIdToken, "userName": username, "newsletter": newsletter});
      var response = await dio.post<String>('/v1/user/register/firebase',
          data: {"address": "Social: $username", "signature": userIdToken, "userName": username, "newsletter": newsletter});
      var convertedData = ResponseModel.fromJson(json.decode(response.data!));
      print(response.data);
      return convertedData;
    } catch (exception) {
      print(exception);
      print((exception as DioError).response!.data);

      return ResponseModel();
    }
  }

  static Future<bool> emailRegister(String email, String pin, String username, bool newsletter) async {
    try {
      var response = await dio.post<String>('/v1/user/register/email',
          data: {"address": email, "guid": pin, "userName": username, "newsletter": newsletter});
      print(response.data);
      return true;
    } catch (exception) {
      print(exception);
      print((exception as DioError).response);
      return false;
    }
  }

  static Future<bool> deleteAccount() async {
    var response = await dio.delete<String>('/v1/user');

    return response.data == null ? false : response.data!.isNotEmpty;
  }
}
