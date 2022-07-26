import 'dart:convert';

import '../../configuration/dio.config.dart';
import '../../models/user/user-info.model.dart';

class SocialRepository {
  SocialRepository._();

  static Future<List<UserInfoData>> searchFriends(String identifier) async {
    try {
      var response = await dio.get<String>('/v1/social/find/$identifier');
      print(response.data);
      var convertedData = jsonDecode(response.data!)
          .map((data) => UserInfoData.fromJson(data))
          .toList();
      return convertedData;
    } catch (exception) {
      return List.empty();
    }
  }
}