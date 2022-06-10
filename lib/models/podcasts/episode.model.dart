import 'package:talkaboat/models/podcasts/podcast.model.dart';

class Episode {
  int? aboatId;
  int? podcastId;
  String? id;
  Null? link;
  String? audio;
  String? image;
  String? title;
  Podcast? podcast;
  String? thumbnail;
  Null? transcript;
  String? description;
  int? pubDateMs;
  Null? guidFromRss;
  Null? listennotesUrl;
  int? audioLengthSec;
  bool? explicitContent;
  bool? maybeAudioInvalid;
  Null? listennotesEditUrl;
  int? playTime;

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
      this.guidFromRss,
      this.listennotesUrl,
      this.audioLengthSec,
      this.explicitContent,
      this.maybeAudioInvalid,
      this.listennotesEditUrl,
      this.playTime});

  Episode.fromJson(Map<String, dynamic> json) {
    aboatId = json['aboat_id'];
    podcastId = json['podcast_id'];
    id = json['id'];
    link = json['link'];
    audio = json['audio'];
    image = json['image'];
    title = json['title'];
    podcast =
        json['podcast'] != null ? new Podcast.fromJson(json['podcast']) : null;
    thumbnail = json['thumbnail'];
    transcript = json['transcript'];
    description = json['description'];
    pubDateMs = json['pub_date_ms'];
    guidFromRss = json['guid_from_rss'];
    listennotesUrl = json['listennotes_url'];
    audioLengthSec = json['audio_length_sec'];
    explicitContent = json['explicit_content'];
    maybeAudioInvalid = json['maybe_audio_invalid'];
    listennotesEditUrl = json['listennotes_edit_url'];
    playTime = json['playTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['aboat_id'] = this.aboatId;
    data['podcast_id'] = this.podcastId;
    data['id'] = this.id;
    data['link'] = this.link;
    data['audio'] = this.audio;
    data['image'] = this.image;
    data['title'] = this.title;
    if (this.podcast != null) {
      data['podcast'] = this.podcast!.toJson();
    }
    data['thumbnail'] = this.thumbnail;
    data['transcript'] = this.transcript;
    data['description'] = this.description;
    data['pub_date_ms'] = this.pubDateMs;
    data['guid_from_rss'] = this.guidFromRss;
    data['listennotes_url'] = this.listennotesUrl;
    data['audio_length_sec'] = this.audioLengthSec;
    data['explicit_content'] = this.explicitContent;
    data['maybe_audio_invalid'] = this.maybeAudioInvalid;
    data['listennotes_edit_url'] = this.listennotesEditUrl;
    data['playTime'] = this.playTime;
    return data;
  }
}
