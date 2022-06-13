import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:talkaboat/configuration/dio.config.dart';
import 'package:talkaboat/models/user/user-info.model.dart';

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
    var response = await Dio().post<String>(
        'https://api.talkaboat.online/v1/user/login/email',
        data: {"address": email, "signature": pin});
    var convertedData = json.decode(response.data!)["token"];
    return convertedData;
  }

  static Future<UserInfo> getUserInfo() async {
    var response = await dio.get<String>('/v1/user/profile');
    var convertedData = UserInfo.fromJson(json.decode(response.data!));
    return convertedData;
  }
}
//hitziger.fabian@live.de
