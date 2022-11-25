import 'package:Talkaboat/models/podcasts/podcast.model.dart';

import '../search/search_result.model.dart';

class Episode extends SearchResult {
  int? episodeId;
  int? podcastId;
  String? link;
  String? audio;
  Podcast? podcast;
  String? thumbnail;
  String? transcript;
  int? pubDateMs;
  num? audioLengthSec;
  bool? explicitContent;
  bool? maybeAudioInvalid;
  num? playTime;

  Episode(
      {this.episodeId,
      this.podcastId,
      super.id,
      super.roomId,
      this.link,
      this.audio,
      super.image,
      super.title,
      this.podcast,
      this.thumbnail,
      this.transcript,
      super.description,
      this.pubDateMs,
      this.audioLengthSec,
      this.explicitContent,
      this.maybeAudioInvalid,
      this.playTime});

  Episode.fromJson(Map<String, dynamic> json) {
    episodeId = json['episodeId'];
    podcastId = json['podcastId'];
    id = json['episodeId'];
    roomId = json['roomId'];
    link = json['link'];
    audio = json['audio'];
    image = json['image'];
    title = json['title'];
    podcast = json['podcast'] != null ? Podcast.fromJson(json['podcast']) : null;
    thumbnail = json['thumbnail'];
    transcript = json['transcript'];
    description = json['description'];
    pubDateMs = json['pubDateInMilliseconds'];
    audioLengthSec = json['audioLengthInSeconds'];
    explicitContent = json['explicitContent'];
    maybeAudioInvalid = json['maybe_audio_invalid'];
    playTime = json['playTime'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['episodeId'] = episodeId;
    data['podcastId'] = podcastId;
    data['id'] = episodeId;
    data['roomId'] = roomId;
    data['link'] = link;
    data['audio'] = audio;
    data['image'] = image;
    data['title'] = title;
    if (podcast != null) {
      data['podcast'] = podcast!.toJson();
    }
    data['thumbnail'] = thumbnail;
    data['transcript'] = transcript;
    data['description'] = description;
    data['pubDateInMilliseconds'] = pubDateMs;
    data['audioLengthInSeconds'] = audioLengthSec;
    data['explicitContent'] = explicitContent;
    data['maybe_audio_invalid'] = maybeAudioInvalid;
    data['playTime'] = playTime;
    return data;
  }
}
