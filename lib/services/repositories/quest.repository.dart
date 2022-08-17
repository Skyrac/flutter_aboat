import 'dart:convert';

import 'package:Talkaboat/configuration/dio.config.dart';
import 'package:dio/dio.dart';

import '../../models/quests/quest-response.model.dart';

class QuestRepository {
  QuestRepository._() {}
  static const API = "/v1/quest";
  static Future<QuestResponse?> getOpenQuests() async {
    try {
      var response = await dio.get<String>(API);
      return QuestResponse.fromJson(jsonDecode(response.data!));
    } catch (e) {
      print(e);
    }
    return null;
  }
}
