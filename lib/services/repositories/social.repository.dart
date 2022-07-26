import 'dart:convert';

import '../../configuration/dio.config.dart';
import '../../models/user/social-user.model.dart';
import '../../models/user/user-info.model.dart';

class SocialRepository {
  SocialRepository._();

  static Future<List<SocialUser>> searchFriends(String identifier) async {
    try {
      var response = await dio.get<String>('/v1/social/find/$identifier');
      var convertedData = List<SocialUser>.from(jsonDecode(response.data!)
          .map((data) => SocialUser.fromJson(data)));
      return convertedData;
    } catch (exception) {
      return List.empty();
    }
  }
}