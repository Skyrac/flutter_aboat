import 'dart:convert';

import 'package:Talkaboat/models/response.model.dart';
import 'package:dio/dio.dart';

import '../../configuration/dio.config.dart';
import '../../models/podcasts/episode.model.dart';
import '../../models/search/search_result.model.dart';

class TokenRepository {
  TokenRepository._() {}
  static const API = "/v1/token";

  static Future<ResponseModel> donateAboatToPodcast(int podcastId, double amount) async {
    try {
      var response = await dio.put<String>('$API/donate/$amount/$podcastId');
      return ResponseModel.fromJson(jsonDecode(response.data!));
    } catch (e) {
      print(e);
    }
    return ResponseModel();
  }
}
