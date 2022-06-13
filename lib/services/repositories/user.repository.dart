import 'package:dio/dio.dart';

class UserRepository {
  UserRepository._();

  static Future<bool> requestEmailLogin(String email) async {
    try {
      print(email);
      var response = await Dio().post<String>(
          'https://api.talkaboat.online/v1/user/login/email/$email');
      print(response.data);
      var convertedData = response.data;
      return convertedData != null;
    } catch (e) {
      print(e);
    }
    return false;
  }
}
//hitziger.fabian@live.de
