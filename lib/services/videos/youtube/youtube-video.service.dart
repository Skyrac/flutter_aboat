import 'dart:convert';

import 'package:Talkaboat/models/videos/youtube/youtube-video-simple.model.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:flutter/material.dart';

import '../../../configuration/dio.config.dart';
import '../../../injection/injector.dart';
import '../../../models/podcasts/podcast-rank.model.dart';

class YouTubeVideoService {
  final userService = getIt<UserService>();

  Future<List<YoutubeVideoSimple>> search(String search, {int? genre, int amount = 10, int offset = 0, Rank? rank, String? language}) async {
    final body = {"amount": amount, "offset": offset, "queue": search};
    if (genre != null) {
      body["genre"] = genre.toString();
    }
    if (rank != null) {
      body["rank"] = rank.id.toString();
    }
    if(language != null) {
      body["Language"] = language;
    }
    try {
      var response = await dio.post<String>(
          'v1/videos/youtube/search', data: body);
      return List<YoutubeVideoSimple>.from(
          json.decode(response.data!).map((data) =>
              YoutubeVideoSimple.fromJson(data)));
    }catch (e) {
      debugPrint("$e");
      return List.empty();
    }
  }
}