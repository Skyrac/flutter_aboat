import 'dart:convert';

import 'package:Talkaboat/configuration/dio.config.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import '../../models/podcasts/episode.model.dart';
import '../../models/search/search_result.model.dart';

class SearchRepository {
  SearchRepository._();
  static Future<List<Episode?>> searchPodcasts(String query) async {
    try {

      await FirebaseAnalytics.instance.logSearch(searchTerm: query);
      var response = await dio.get<String>('/v1/podcast/3855/episodes/asc/0/10');
      var l = jsonDecode(response.data!);
      List<Episode> episodes = List<Episode>.from(l.map((model) => Episode.fromJson(model)));
      return episodes;
    } catch (e) {
      debugPrint("$e");
    }
    return List.generate(0, (index) => null);
  }

  static Future<List<SearchResult>?> searchSuggestion(String query, {String? languages, String? genres}) async {
    try {
      await FirebaseAnalytics.instance.logSearch(searchTerm: query);
      var response = await dio.get<String>('/v1/podcast/search/typeahead/$query/detail');
      var list = List<SearchResult>.from(json.decode(response.data!).map((data) => SearchResult.fromJson(data)));
      return list;
    } catch (e) {
      debugPrint("$e");
    }
    return null;
  }

//https://api.talkaboat.online/v1/podcast/3855/desc/0/10
}
