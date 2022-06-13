import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/user.repository.dart';

class UserService {
  String token = "";
  late final prefs;
  static const String TOKEN_IDENTIFIER = "aboat_token";

  setInitialValues() async {
    prefs = await SharedPreferences.getInstance();

    // var secToken = prefs.getString(TOKEN_IDENTIFIER);
    // if (secToken != null) {
    //   token = secToken;
    // }
  }

  static Future<UserService> init() async {
    var userService = UserService();
    await userService.setInitialValues();
    return userService;
  }

  Future<bool> emailLogin(String email, String pin) async {
    token = await UserRepository.emailLogin(email, pin);
    prefs.setString(TOKEN_IDENTIFIER, token);
    if (token.isNotEmpty) {
      return await getUserInfo();
    }
    return false;
  }

  Future<bool> getUserInfo() async {
    return true;
  }
}
