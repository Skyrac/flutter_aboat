import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../configuration/dio.config.dart';
import '../../models/user/social-user.model.dart';

class SocialRepository {
  SocialRepository._();

  static Future<List<SocialUser>> getFriends({int amount = 0, int offset = 0}) async {
    try {
      var response = await dio.get<String>('/v1/social/friends/$amount/$offset');

      var convertedData =
          List<SocialUser>.from(jsonDecode(response.data!).map((data) => SocialUser.fromJson(data)), growable: true);
      return convertedData;
    } catch (exception) {
      return List.empty();
    }
  }

  static Future<List<SocialUser>> getPendingFriends({int amount = 0, int offset = 0}) async {
    try {
      var response = await dio.get<String>('/v1/social/friends/requests/outgoing/$amount/$offset');

      var convertedData =
          List<SocialUser>.from(jsonDecode(response.data!).map((data) => SocialUser.fromJson(data)), growable: true);
      return convertedData;
    } catch (exception) {
      return List.empty();
    }
  }

  static Future<List<SocialUser>> getFriendRequests({int amount = 0, int offset = 0}) async {
    try {
      var response = await dio.get<String>('/v1/social/friends/requests/incoming/$amount/$offset');

      var convertedData =
          List<SocialUser>.from(jsonDecode(response.data!).map((data) => SocialUser.fromJson(data)), growable: true);
      return convertedData;
    } catch (exception) {
      return List.empty();
    }
  }

  static Future<List<SocialUser>> getFriendSuggestions({int amount = 0, int offset = 0}) async {
    try {
      var response = await dio.get<String>('/v1/social/friends/suggestions/$amount/$offset');

      var convertedData =
          List<SocialUser>.from(jsonDecode(response.data!).map((data) => SocialUser.fromJson(data)), growable: true);
      return convertedData;
    } catch (exception) {
      return List.empty();
    }
  }

  static Future<List<SocialUser>> searchFriends(String identifier) async {
    try {
      var response = await dio.get<String>('/v1/social/find/$identifier');
      var convertedData =
          List<SocialUser>.from(jsonDecode(response.data!).map((data) => SocialUser.fromJson(data)), growable: true);
      return convertedData;
    } catch (exception) {
      return List.empty();
    }
  }

  static Future<bool> requestFriend(int userId) async {
    try {
      var response = await dio.post<bool>('/v1/social/request/$userId');
      return response.data!;
    } catch (exception) {
      return false;
    }
  }

  static Future<bool> pullbackFriend(int userId) async {
    try {
      var response = await dio.post<bool>('/v1/social/pullback/$userId');
      return response.data!;
    } catch (exception) {
      return false;
    }
  }

  static Future<bool> declineFriendRequest(int userId) async {
    try {
      var response = await dio.post<bool>('/v1/social/decline/$userId');
      return response.data!;
    } catch (exception) {
      return false;
    }
  }

  static Future<bool> acceptFriendRequest(int userId) async {
    try {
      var response = await dio.post<bool>('/v1/social/accept/$userId');
      return response.data!;
    } catch (e) {
      debugPrint("$e");
      return false;
    }
  }

  static Future<bool> removeFriend(int userId) async {
    try {
      var response = await dio.delete<bool>('/v1/social/remove/$userId');
      return response.data!;
    } catch (e) {
      debugPrint("$e");
      return false;
    }
  }
}
