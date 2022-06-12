import 'dart:convert';
import '../../models/podcasts/episode.model.dart';
import 'package:dio/dio.dart';

class SearchRepository {
  SearchRepository._() {}
  static Future<List<Episode?>> searchPodcasts(String query) async {
    try {
      var response = await Dio().get<String>('https://api.talkaboat.online/v1/podcast/3855/episodes/asc/0/10');
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

  static Future<List<String>> searchSuggestion(String query) async {
    try {
      var response = await Dio().get<String>('https://api.talkaboat.online/v1/podcast/search/typeahead/$query');
      print(response);
      List<String> l = List.from(jsonDecode(response.data!));
      return l;
    } catch (e) {
      print(e);
    }
    return List.generate(0, (index) => '');
  }

//https://api.talkaboat.online/v1/podcast/3855/desc/0/10
}
