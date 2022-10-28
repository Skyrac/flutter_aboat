import 'dart:convert';
import 'package:Talkaboat/models/live/live-session.model.dart';
import 'package:Talkaboat/models/response.model.dart';

import '../../configuration/dio.config.dart';
import '../../models/podcasts/podcast.model.dart';

class LiveSessionRepository {
  LiveSessionRepository._() {}
  static const API = "/v1/live";

  static Future<List<Podcast>> getRandomPodcastByGenre(
      int amount, int genre) async {
    try {
      var response = await dio.get<String>('$API/search/random/$amount/$genre');
      var list = List<Podcast>.from(
          json.decode(response.data!).map((data) => Podcast.fromJson(data)));
      return list;
    } catch (ex) {
      return List.empty();
    }
  }

  static Future<ResponseModel> getToken(String roomGuid) async {
    var response = await dio.get<String>('$API/authorize/$roomGuid');
    var data = ResponseModel.fromJson(json.decode(response.data!));
    return data;
  }

  static Future<LiveSession> openRoom(configuration) async {
    var response = await dio.post<String>('$API/room', data: configuration);
    var data = LiveSession.fromJson(json.decode(response.data!));
    return data;
  }
}
