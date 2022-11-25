import 'dart:convert';
import 'package:Talkaboat/models/live/live-session-configuration.model.dart';
import 'package:Talkaboat/models/live/live-session.model.dart';
import 'package:Talkaboat/models/response.model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../configuration/dio.config.dart';

class LiveSessionRepository {
  LiveSessionRepository._();
  static const API = "/v1/live";

  static Future<List<LiveSession>> getLiveSessions(String search, int amount, int offset) async {
    try {
      final body = {"amount": amount, "offset": offset, "queue": search};
      var response = await dio.post<String>('$API/rooms/search', data: body);
      debugPrint(response.data);
      var list = List<LiveSession>.from(json.decode(response.data!).map((data) => LiveSession.fromJson(data)));
      return list;
    } catch (ex) {
      debugPrint("$ex");
      debugPrint((ex as DioError).response?.data);
      return List.empty();
    }
  }

  static Future<ResponseModel> getToken(String roomGuid) async {
    try {
      var response = await dio.get<String>('$API/authorize/$roomGuid');
      var data = ResponseModel.fromJson(json.decode(response.data!));
      return data;
    } catch (e) {
      debugPrint("$e");
      debugPrint((e as DioError).response?.data);
      return ResponseModel();
    }
  }

  static Future<LiveSession?> openRoom(LiveSessionConfiguration configuration) async {
    try {
      var response = await dio.post<String>('$API/room', data: configuration);
      var data = LiveSession.fromJson(json.decode(response.data!));
      return data;
    } catch (e) {
      debugPrint("$e");
      debugPrint((e as DioError).response?.data);
      return null;
    }
  }
}
