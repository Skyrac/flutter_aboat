import 'dart:convert';
import 'package:Talkaboat/models/live/live-session-configuration.model.dart';
import 'package:Talkaboat/models/live/live-session.model.dart';
import 'package:Talkaboat/models/response.model.dart';
import 'package:dio/dio.dart';

import '../../configuration/dio.config.dart';

class LiveSessionRepository {
  LiveSessionRepository._();
  static const API = "/v1/live";

  static Future<List<LiveSession>> getLiveSessions(String search, int amount, int offset) async {
    return Future.value([
      LiveSession(
          guid: "3",
          hosts: [1, 2, 3],
          superHost: 3,
          started: "wann",
          configuration: LiveSessionConfiguration(
              roomName: "room",
              password: "pw",
              onlyClubhouse: false,
              onlySuperhostCanAddHost: true,
              onlySuperhostCanRemoveHost: true))
    ]);
    /*try {
      final body = {"amount": amount, "offset": offset, "queue": search};
      var response = await dio.get<String>('$API/rooms/$amount/$offset');
      print(response.data);
      var list = List<LiveSession>.from(json.decode(response.data!).map((data) => LiveSession.fromJson(data)));
      return list;
    } catch (ex) {
      print(ex);
      print((ex as DioError).response?.data);
      return List.empty();
    }*/
  }

  static Future<ResponseModel> getToken(String roomGuid) async {
    try {
      var response = await dio.get<String>('$API/authorize/$roomGuid');
      var data = ResponseModel.fromJson(json.decode(response.data!));
      return data;
    } catch (e) {
      print(e);
      print((e as DioError).response?.data);
      return ResponseModel();
    }
  }

  static Future<LiveSession?> openRoom(LiveSessionConfiguration configuration) async {
    try {
      var response = await dio.post<String>('$API/room', data: configuration);
      var data = LiveSession.fromJson(json.decode(response.data!));
      return data;
    } catch (e) {
      print(e);
      print((e as DioError).response?.data);
      return null;
    }
  }
}
