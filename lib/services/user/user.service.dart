import 'package:shared_preferences/shared_preferences.dart';
import 'package:talkaboat/models/podcasts/podcast.model.dart';
import 'package:talkaboat/models/user/user-info.model.dart';

import '../../models/playlist/playlist.model.dart';
import '../repositories/podcast.repository.dart';
import '../repositories/user.repository.dart';

class UserService {
  String token = "";
  UserInfo? userInfo;
  List<Podcast> library = List.empty();
  List<Playlist> playlists = List.empty();
  late final prefs;
  static const String TOKEN_IDENTIFIER = "aboat_token";

  get isConnected => token.isNotEmpty && userInfo != null;
  isInLibrary(int id) => library.any((element) => element.aboatId == id);

  setInitialValues() async {
    prefs = await SharedPreferences.getInstance();

    var secToken = prefs.getString(TOKEN_IDENTIFIER);
    if (secToken != null) {
      token = secToken;
      print("Security Token: $token");
    }
  }

  static Future<UserService> init() async {
    var userService = UserService();
    await userService.setInitialValues();
    return userService;
  }

  getCoreData() async {
    if (token.isNotEmpty) {
      await getUserInfo();
    }
  }

  Future<bool> getUserInfo() async {
    userInfo = await UserRepository.getUserInfo();
    if (userInfo == null || userInfo!.userName == null) {
      logout();
      return false;
    }
    return true;
  }

  Future<bool> emailLogin(String email, String pin) async {
    token = await UserRepository.emailLogin(email, pin);
    prefs.setString(TOKEN_IDENTIFIER, token);
    if (token.isNotEmpty) {
      return await getUserInfo();
    }
    return false;
  }

  logout() async {
    token = "";
    userInfo = null;
    await prefs.setString(TOKEN_IDENTIFIER, "");
  }

  //#region Playlist
  Future<List<Playlist>> getPlaylists() async {
    var newPlaylists = await PodcastRepository.getPlaylists();
    for (final playlist in newPlaylists) {
      playlist.tracks!.sort(
          (trackA, trackB) => trackA.position!.compareTo(trackB.position!));
    }
    playlists = newPlaylists;
    return newPlaylists;
  }

  Future<Playlist> changePlaylistPosition(
      int podcastId, int trackId, int position) async {
    var newPlaylist = await PodcastRepository.changeEpisodePositionInPlaylist(
        podcastId, trackId, position);
    var playlist = playlists[playlists
        .indexWhere((element) => element.playlistId == newPlaylist.playlistId)];
    playlist.tracks!
        .sort((trackA, trackB) => trackA.position!.compareTo(trackB.position!));
    playlist.tracks = newPlaylist.tracks;
    return playlist;
  }

  Future<Playlist> removeFromPlaylistByTrackId(
      int playlistId, int playlistTrackId) async {
    var newPlaylist = await PodcastRepository.removeEpisodeFromPlaylist(
        playlistId, playlistTrackId);
    var playlist = playlists[playlists
        .indexWhere((element) => element.playlistId == newPlaylist.playlistId)];
    playlist.tracks!
        .sort((trackA, trackB) => trackA.position!.compareTo(trackB.position!));
    playlist.tracks = newPlaylist.tracks;
    return playlist;
  }

  Future<Playlist> removeFromPlaylistByEpisodeId(
      int playlistId, int episodeId) async {
    var playlist = playlists[
        playlists.indexWhere((element) => element.playlistId == playlistId)];
    var track = playlist.tracks
        ?.firstWhere((element) => element.episodeId == episodeId);
    if (track == null) {
      return playlist;
    }
    var newPlaylist = await PodcastRepository.removeEpisodeFromPlaylist(
        playlistId, track.playlistTrackId!);

    playlist.tracks!
        .sort((trackA, trackB) => trackA.position!.compareTo(trackB.position!));
    playlist.tracks = newPlaylist.tracks;
    return playlist;
  }

  Future<Playlist> addToPlaylist(int playlistId, int episodeId) async {
    var newPlaylist =
        await PodcastRepository.addToPlaylist(playlistId, episodeId);
    var playlist = playlists[playlists
        .indexWhere((element) => element.playlistId == newPlaylist.playlistId)];
    playlist.tracks!
        .sort((trackA, trackB) => trackA.position!.compareTo(trackB.position!));
    playlist.tracks = newPlaylist.tracks;
    return playlist;
  }
  //#endregion

  //#region Library
  Future<List<Podcast>> getLibrary() async {
    var newLibrary = await PodcastRepository.getUserLibrary();
    library = newLibrary;
    return newLibrary;
  }

  Future<List<Podcast>> removeFromLibrary(int id) async {
    if (await PodcastRepository.removeFromLibrary(id)) {
      library.removeWhere((item) => item.aboatId == id);
    }
    return library;
  }

  Future<List<Podcast>> addToLibrary(int id) async {
    if (await PodcastRepository.addToLibrary(id)) {
      return await getLibrary();
    }
    return library;
  }

  Future<List<Podcast>> toggleLibraryEntry(id) async {
    if (isInLibrary(id)) {
      return await removeFromLibrary(id);
    }
    return await addToLibrary(id);
  }

  //#endregion

}
