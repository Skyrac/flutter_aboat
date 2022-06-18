import 'package:shared_preferences/shared_preferences.dart';
import 'package:talkaboat/models/podcasts/podcast.model.dart';
import 'package:talkaboat/models/user/user-info.model.dart';

import '../../models/playlist/playlist.model.dart';
import '../../models/rewards/reward.model.dart';
import '../repositories/podcast.repository.dart';
import '../repositories/user.repository.dart';

class UserService {
  String token = "";
  UserInfo? userInfo;
  List<Podcast> library = List.empty();
  List<Playlist> playlists = List.empty();
  Reward rewards = Reward();
  late final prefs;
  static const String TOKEN_IDENTIFIER = "aboat_token";

  get isConnected => token.isNotEmpty && userInfo != null;
  Stream<Reward> rewardStream() async* {
    while (true) {
      await Future.delayed(Duration(milliseconds: 500));
      yield rewards;
    }
  }

  isInLibrary(int id) => library.any((element) => element.aboatId == id);

  setInitialValues() async {
    prefs = await SharedPreferences.getInstance();

    var secToken = prefs.getString(TOKEN_IDENTIFIER);
    if (secToken != null) {
      token = secToken;
    }
  }

  updateRewards(Reward newRewards) {
    rewards = newRewards;
  }

  static Future<UserService> init() async {
    var userService = UserService();
    await userService.setInitialValues();
    return userService;
  }

  getCoreData() async {
    if (token.isNotEmpty) {
      await getUserInfo();
      if (userInfo != null) {
        rewards = await UserRepository.getUserRewards();
      }
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
      await getCoreData();
      return userInfo != null;
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

  Future<bool> createPlaylist(String text) async {
    if (text.isEmpty) {
      return false;
    }
    var newPlaylist = await PodcastRepository.createPlaylist(text);
    if (newPlaylist.name != null &&
        newPlaylist.name!.isNotEmpty &&
        !playlists
            .any((playlist) => playlist.playlistId == newPlaylist.playlistId)) {
      playlists.add(newPlaylist);
      return true;
    }
    return false;
  }

  Future<bool> removePlaylist(int playlistId) async {
    if (playlists.any((element) => element.playlistId == playlistId)) {
      var result = await PodcastRepository.removePlaylist(playlistId);
      if (result != null && result) {
        playlists.removeWhere((element) => element.playlistId == playlistId);
        return result;
      }
    }
    return false;
  }

  //#endregion

}
