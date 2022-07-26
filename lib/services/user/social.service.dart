import 'dart:convert';

import 'package:Talkaboat/services/repositories/social.repository.dart';

import '../../configuration/dio.config.dart';
import '../../models/user/user-info.model.dart';

class SocialService {

  Future<List<UserInfoData>> SearchFriends(String identifier) async {
    var potentialFriends = await SocialRepository.searchFriends(identifier);
    return potentialFriends;
  }

}