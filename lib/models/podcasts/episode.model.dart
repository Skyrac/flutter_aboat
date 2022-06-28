import 'package:talkaboat/models/podcasts/podcast.model.dart';
import 'package:talkaboat/models/search/search_result.model.dart';

class Episode extends SearchResult {
  int? aboatId;
  int? podcastId;
  @override
  int? id;
  String? link;
  String? audio;
  @override
  String? image;
  @override
  String? title;
  Podcast? podcast;
  String? thumbnail;
  String? transcript;
  @override
  String? description;
  int? pubDateMs;
  num? audioLengthSec;
  bool? explicitContent;
  bool? maybeAudioInvalid;
  num? playTime;

  Episode(
      {this.aboatId,
      this.podcastId,
      this.id,
      this.link,
      this.audio,
      this.image,
      this.title,
      this.podcast,
      this.thumbnail,
      this.transcript,
      this.description,
      this.pubDateMs,
      this.audioLengthSec,
      this.explicitContent,
      this.maybeAudioInvalid,
      this.playTime});

  Episode.fromJson(Map<String, dynamic> json) {
    aboatId = json['aboat_id'];
    podcastId = json['podcast_id'];
    id = json['aboat_id'];
    link = json['link'];
    audio = json['audio'];
    image = json['image'];
    title = json['title'];
    podcast =
        json['podcast'] != null ? Podcast.fromJson(json['podcast']) : null;
    thumbnail = json['thumbnail'];
    transcript = json['transcript'];
    description = json['description'];
    pubDateMs = json['pub_date_ms'];
    audioLengthSec = json['audio_length_sec'];
    explicitContent = json['explicit_content'];
    maybeAudioInvalid = json['maybe_audio_invalid'];
    playTime = json['playTime'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['aboat_id'] = aboatId;
    data['podcast_id'] = podcastId;
    data['id'] = aboatId;
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
    data['pub_date_ms'] = pubDateMs;
    data['audio_length_sec'] = audioLengthSec;
    data['explicit_content'] = explicitContent;
    data['maybe_audio_invalid'] = maybeAudioInvalid;
    data['playTime'] = playTime;
    return data;
  }
}
