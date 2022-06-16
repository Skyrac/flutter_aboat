import '../podcasts/episode.model.dart';

class Track {
  int? playlistTrackId;
  int? playlistId;
  int? episodeId;
  Episode? episode;
  String? created;
  int? position;

  Track(
      {this.playlistTrackId,
      this.playlistId,
      this.episodeId,
      this.episode,
      this.created,
      this.position});

  Track.fromJson(Map<String, dynamic> json) {
    playlistTrackId = json['playlistTrack_Id'];
    playlistId = json['playlist_Id'];
    episodeId = json['episode_Id'];
    episode =
        json['episode'] != null ? Episode.fromJson(json['episode']) : null;
    created = json['created'];
    position = json['position'];
  }

  @override
  String toString() {
    return "$position: ${episode!.title}";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['playlistTrack_Id'] = playlistTrackId;
    data['playlist_Id'] = playlistId;
    data['episode_Id'] = episodeId;
    if (episode != null) {
      data['episode'] = episode!.toJson();
    }
    data['created'] = created;
    data['position'] = position;
    return data;
  }
}
