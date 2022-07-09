import 'dart:convert';

import 'package:dio/dio.dart';

import '../../configuration/dio.config.dart';
import '../../models/playlist/playlist.model.dart';
import '../../models/podcasts/episode.model.dart';
import '../../models/podcasts/podcast.model.dart';
import '../../models/response.model.dart';

class PodcastRepository {
  PodcastRepository._() {}
  static const API = "/v1/podcast";
  static Future<List<Episode?>> getEpisodesMock(int podcastId) async {
    try {
      var response = await Dio().get<String>(
          'https://api.talkaboat.online/v1/podcast/3855/episodes/asc/0/10');
      var l = jsonDecode(response.data!);
      List<Episode> episodes =
          List<Episode>.from(l.map((model) => Episode.fromJson(model)));
      return episodes;
    } catch (e) {
      print(e);
    }
    return List.generate(0, (index) => null);
  }

  static Future<List<Podcast>> getRandomPodcast(int amount) async {
    try {
      var response = await dio.get<String>('$API/search/random/$amount');
      var list = List<Podcast>.from(
          json.decode(response.data!).map((data) => Podcast.fromJson(data)));
      return list;
    } catch (ex) {
      return List.empty();
    }
  }

  static Future<ResponseModel> getPodcastOwnership(int podcastId) async {
    try {
      var response = await dio.get<String>('$API/ownership/$podcastId');
      return ResponseModel.fromJson(json.decode(response.data!));
    } catch(ex) {
      return ResponseModel(text: 'error');
    }
  }

  static Future<List<Podcast>> getRandomPodcastByGenre(
      int amount, int genre) async {
    try {
      var response = await dio.get<String>('$API/search/random/$amount/$genre');
      var list = List<Podcast>.from(
          json.decode(response.data!).map((data) => Podcast.fromJson(data)));
      return list;
    } catch (ex) {
      return List.empty();
    }
  }

  static Future<List<Episode>> getEpisodesOfPodcast(
      int id, String? sort, int? amount, int? offset) async {
    final body = {
      "amount": amount ?? -1,
      "id": id,
      "offset": offset ?? 0,
      "sort": sort ?? "desc"
    };
    var response = await dio.post<String>('$API/detail', data: body);
    var podcast = Podcast.fromJson(json.decode(response.data!));
    return podcast.episodes ?? List.empty();
  }

  static Future<List<Podcast>> getUserLibrary() async {
    var response = await dio.get<String>('$API/library/detail');
    var list = List<Podcast>.from(
        json.decode(response.data!).map((data) => Podcast.fromJson(data)));
    return list;
  }

  static Future<bool> removeFromLibrary(int id) async {
    var response = await dio.post<bool>('$API/library/remove/$id');
    return response.data!;
  }

  static Future<bool> addToLibrary(int id) async {
    var response = await dio.post<bool>('$API/library/add/$id');
    return response.data!;
  }

  static Future<List<Playlist>> getPlaylists() async {
    var response = await dio.get<String>('$API/playlist');
    var list = List<Playlist>.from(
        json.decode(response.data!).map((data) => Playlist.fromJson(data)));
    return list;
  }

  static Future<Playlist> changeEpisodePositionInPlaylist(
      int podcastId, int trackId, int position) async {
    var response = await dio
        .put<String>('$API/playlist/$podcastId/update/$trackId/$position');
    var convertedData = Playlist.fromJson(json.decode(response.data!));
    return convertedData;
  }

  static Future<Playlist> removeEpisodeFromPlaylist(
      int playlistId, int playlistTrackId) async {
    var response = await dio
        .delete<String>('$API/playlist/$playlistId/delete/$playlistTrackId');
    var convertedData = Playlist.fromJson(json.decode(response.data!));
    return convertedData;
  }

  static Future<Playlist> addToPlaylist(int playlistId, int episodeId) async {
    var response =
        await dio.post<String>('$API/playlist/$playlistId/add/$episodeId');
    var convertedData = Playlist.fromJson(json.decode(response.data!));
    return convertedData;
  }

  static Future<Playlist> createPlaylist(String name,
      {List<Episode>? tracks, String? image}) async {
    tracks ??= List<Episode>.empty();
    image ??= "";
    var dataToSend = {"name": name, "image": image, "tracks": tracks};
    var response = await dio.post<String>('$API/playlist', data: dataToSend);
    var convertedData = Playlist.fromJson(json.decode(response.data!));
    return convertedData;
  }

  static Future<bool?> removePlaylist(int playlistId) async {
    var response = await dio.delete<bool>('$API/playlist/$playlistId');

    return response.data;
  }

  //https://api.talkaboat.online/v1/podcast/3855/desc/0/10
}
