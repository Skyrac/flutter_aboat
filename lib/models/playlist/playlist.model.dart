import 'package:jiffy/jiffy.dart';
import 'package:talkaboat/models/playlist/track.model.dart';

class Playlist {
  int? playlistId;
  String? name;
  String? image;
  List<Track>? tracks;
  String? created;
  String? modified;

  Playlist(
      {this.playlistId,
      this.name,
      this.image,
      this.tracks,
      this.created,
      this.modified});

  Playlist.fromJson(Map<String, dynamic> json) {
    playlistId = json['playlist_Id'];
    name = json['name'];
    image = json['image'];
    if (json['tracks'] != null) {
      tracks = <Track>[];
      json['tracks'].forEach((v) {
        tracks!.add(Track.fromJson(v));
      });
    }
    created = json['created'];
    modified = json['modified'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['playlist_Id'] = playlistId;
    data['name'] = name;
    data['image'] = image;
    if (tracks != null) {
      data['tracks'] = tracks!.map((v) => v.toJson()).toList();
    }
    data['created'] = created;
    data['modified'] = modified;
    return data;
  }

  bool containsEpisode(int episodeId) {
    return tracks!.any((element) => element.episodeId == episodeId);
  }

  getDateTime() {
    return Jiffy(created!).yMMMd; // DateTime.parse(created!).
  }
}
