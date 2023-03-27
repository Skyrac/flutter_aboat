import 'package:Talkaboat/models/podcasts/podcast_reward_dto.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../search/search_result.model.dart';
import 'episode.model.dart';

part 'podcast.model.g.dart';

@JsonSerializable()
class Podcast extends SearchResult {
  int? podcastId;
  String? image;
  String? genres;
  String? rss;
  String? email;
  List<Episode>? episodes;
  String? title;
  String? country;
  String? website;
  String? language;
  String? publisher;
  String? description;
  String? shortDescription;
  int? totalEpisodes;
  bool? explicitContent;
  int? latestPubDate;
  int? roomId;
  int? rank;
  DateTime? lastUpdate;
  List<PodcastRewardDto>? rewardTokens;

  Podcast(
    this.podcastId,
    this.image,
    this.genres,
    this.rss,
    this.email,
    this.episodes,
    this.title,
    this.country,
    this.website,
    this.language,
    this.publisher,
    this.description,
    this.shortDescription,
    this.totalEpisodes,
    this.explicitContent,
    this.latestPubDate,
    this.roomId,
    this.rank,
    this.lastUpdate,
    this.rewardTokens,
  );

  factory Podcast.fromJson(Map<String, dynamic> json) {
    var podcast = _$PodcastFromJson(json);
    podcast.id = podcast.podcastId;
    return podcast;
  }

  @override
  Map<String, dynamic> toJson() {
    var map = _$PodcastToJson(this);
    map['id'] = podcastId;
    debugPrint(map["id"].toString());
    return map;
  }

  static Podcast empty() {
    return Podcast(
      0, // Default podcastId
      'default_image.png', // Default image
      '1,2,3', // Default genres
      'http://example.com/rss', // Default RSS
      'default@example.com', // Default email
      [], // Default empty episodes list
      'Default Title', // Default title
      'Default Country', // Default country
      'http://example.com', // Default website
      'en', // Default language
      'Default Publisher', // Default publisher
      'Default description', // Default description
      'Default short description', // Default short description
      0, // Default totalEpisodes
      false, // Default explicitContent
      0, // Default latestPubDate
      0, // Default roomId
      0, // Default rank
      DateTime.now(), // Default lastUpdate
      [], // Default empty rewardTokens list
    );
  }
}
