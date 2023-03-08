import 'dart:convert';

import 'package:Talkaboat/models/response.model.dart';
import 'package:Talkaboat/models/stormm/stormm-mission.model.dart';
import 'package:flutter/foundation.dart';
import 'package:tweet_ui/models/api/v2/tweet_v2.dart';

import '../../configuration/dio.config.dart';

class SocialMediaRepository {
  SocialMediaRepository._();
  static const API = "/v1/socialmedia";

  static Future<List<TweetV2Response>> getNews() async {
    try {
      var response = await dio.get<String>('$API/timeline');

      final list = List<TweetV2Response>.from(json.decode(response.data!).map((data) => TweetV2Response(data: data)));

      return list;
    } catch (e) {
      debugPrint("$e");
    }
    return List.empty();

  }
}

/*

for(var tweet in snapshot.data!) {
                  EmbeddedTweetView.fromTweetV2(TweetV2Response.fromRawJson("$tweet"),
                    darkMode: true,
                    videoHighQuality: false,
                  );
                }
 */
