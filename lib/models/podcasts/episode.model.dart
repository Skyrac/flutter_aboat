import 'package:Talkaboat/models/podcasts/podcast.model.dart';

import '../search/search_result.model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'episode.model.g.dart';

@JsonSerializable()
class Episode extends SearchResult {
  int? episodeId;
  int? podcastId;
  String? link;
  Podcast? podcast;
  String? audio;
  @override
  String? image;
  @override
  String? title;
  String? transcript;
  @override
  String? description;
  int? pubDateInMilliseconds;
  int? audioLengthInSeconds;
  bool? explicitContent;
  int? playTime;
  bool? isDeleted;
  @override
  int? roomId;

  Episode(
    this.episodeId,
    this.podcastId,
    this.link,
    this.podcast,
    this.audio,
    this.image,
    this.title,
    this.transcript,
    this.description,
    this.pubDateInMilliseconds,
    this.audioLengthInSeconds,
    this.explicitContent,
    this.playTime,
    this.isDeleted,
      this.roomId
  );

  factory Episode.fromJson(Map<String, dynamic> json) {
    var episode = _$EpisodeFromJson(json);
    episode.id = episode.episodeId;
    return episode;
  }

  @override
  Map<String, dynamic> toJson() {
    var map = _$EpisodeToJson(this);
    map["id"] = episodeId;
    return map;
  }
}
