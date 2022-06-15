import 'package:shared_preferences/shared_preferences.dart';
import 'package:talkaboat/models/podcasts/podcast.model.dart';
import 'package:talkaboat/models/user/user-info.model.dart';

import '../repositories/podcast.repository.dart';
import '../repositories/user.repository.dart';

class UserService {
  String token = "";
  UserInfo? userInfo;
  List<Podcast> library = List.empty();
  late final prefs;
  static const String TOKEN_IDENTIFIER = "aboat_token";

  get isConnected => token.isNotEmpty && userInfo != null;
  isInLibrary(int id) => library.any((element) => element.aboatId == id);

  setInitialValues() async {
    prefs = await SharedPreferences.getInstance();

    var secToken = prefs.getString(TOKEN_IDENTIFIER);
    if (secToken != null) {
      token = secToken;
      print("Security Token: $token");
    }
  }

  static Future<UserService> init() async {
    var userService = UserService();
    await userService.setInitialValues();
    return userService;
  }

  getCoreData() async {
    if (token.isNotEmpty) {
      await getUserInfo();
    }
  }

  Future<bool> getUserInfo() async {
    userInfo = await UserRepository.getUserInfo();
    return true;
  }

  Future<bool> emailLogin(String email, String pin) async {
    token = await UserRepository.emailLogin(email, pin);
    prefs.setString(TOKEN_IDENTIFIER, token);
    if (token.isNotEmpty) {
      return await getUserInfo();
    }
    return false;
  }

  logout() async {
    token = "";
    userInfo = null;
    await prefs.setString(TOKEN_IDENTIFIER, "");
  }

  Future<List<Podcast>> getLibrary() async {
    var newLibrary = await PodcastRepository.getUserLibrary();
    library = newLibrary;
    return newLibrary;
  }

  Future<List<Podcast>> removeFromLibrary(int id) async {
    if (await PodcastRepository.removeFromLibrary(id)) {
      library.removeWhere((item) => item.aboatId == id);
    }
    return library;
  }

  Future<List<Podcast>> addToLibrary(int id) async {
    if (await PodcastRepository.addToLibrary(id)) {
      return await getLibrary();
    }
    return library;
  }

  Future<List<Podcast>> toggleLibraryEntry(id) async {
    if (isInLibrary(id)) {
      return await removeFromLibrary(id);
    }
    return await addToLibrary(id);
  }
}
