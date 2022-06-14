import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:talkaboat/configuration/dio.config.dart';

import '../../models/podcasts/episode.model.dart';
import '../../models/podcasts/podcast.model.dart';

class PodcastRepository {
  PodcastRepository._() {}
  static const API = "/v1/podcast";
  static Future<List<Episode?>> getEpisodesMock(int podcastId) async {
    try {
      var response = await Dio().get<String>(
          'https://api.talkaboat.online/v1/podcast/3855/episodes/asc/0/10');
      print(response);
      var l = jsonDecode(response.data!);
      List<Episode> episodes =
          List<Episode>.from(l.map((model) => Episode.fromJson(model)));
      return episodes;
    } catch (e) {
      print(e);
    }
    return List.generate(0, (index) => null);
  }

  static Future<List<Podcast>> getRandomPodcast(int amount) async {
    var response = await dio.get<String>('$API/random/$amount');
    print(response);
    var list = List<Podcast>.from(
        json.decode(response.data!).map((data) => Podcast.fromJson(data)));
    return list;
  }

  static Future<List<Podcast>> getRandomPodcastByGenre(
      int amount, int genre) async {
    var response = await dio.get<String>('$API/random/$amount/$genre');
    var list = List<Podcast>.from(
        json.decode(response.data!).map((data) => Podcast.fromJson(data)));
    return list;
  }

  //https://api.talkaboat.online/v1/podcast/3855/desc/0/10
}
