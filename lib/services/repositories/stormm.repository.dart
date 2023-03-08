import 'dart:convert';

import 'package:Talkaboat/models/response.model.dart';
import 'package:Talkaboat/models/stormm/stormm-mission.model.dart';
import 'package:flutter/foundation.dart';

import '../../configuration/dio.config.dart';

class StormmRepository {
  StormmRepository._();
  static const API = "/v1/stormm";

  static Future<List<StormmMission>> getStormmMissions() async {
    try {
      var response = await dio.get<String>('$API');
      return List<StormmMission>.from(json.decode(response.data!).map((data) => StormmMission.fromJson(data)));
    } catch (e) {
      debugPrint("$e");
    }
    return List.empty();
  }
}
