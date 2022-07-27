import 'dart:convert';
import 'dart:math';

import 'package:Talkaboat/services/user/social.service.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../injection/injector.dart';
import '../../models/playlist/playlist.model.dart';
import '../../models/podcasts/podcast.model.dart';
import '../../models/response.model.dart';
import '../../models/rewards/reward.model.dart';
import '../../models/user/user-info.model.dart';
import '../repositories/podcast.repository.dart';
import '../repositories/user.repository.dart';

enum SocialLogin { Google, Facebook, Apple }

class UserService {
  String token = "";
  String firebaseToken = "";
  UserInfoData? userInfo;
  List<Podcast> library = List.empty();
  List<Playlist> playlists = List.empty();
  Reward rewards = Reward();
  Map<int, List<Podcast>> podcastProposalsHomeScreen = {};
  ResponseModel? lastConnectionState;
  DateTime? lastNotificationSeen;
  final friendService = getIt<SocialService>();
  Map<int, DateTime?> lastPodcastUpdateSeen = {};
  late final prefs;
  var isSignin = false;
  var baseLogin = false;
  static const String TOKEN_IDENTIFIER = "aboat_token";
  static const String LAST_NOTIFICATION_UPDATE = "last_update_seen";

  get isConnected => token.isNotEmpty && userInfo != null;

  get availableToken => rewards.vested;
  Stream<Reward> rewardStream() async* {
    while (true) {
      await Future.delayed(Duration(milliseconds: 500));
      yield rewards;
    }
  }

  Future<bool> socialLogin(SocialLogin socialType, BuildContext context) async {
    UserCredential? credential;
    isSignin = true;
    baseLogin = false;
    switch (socialType) {
      case SocialLogin.Google:
        credential = await signInWithGoogle(context);
        break;
      case SocialLogin.Facebook:
        credential = await signInWithFacebook();
        break;
      case SocialLogin.Apple:
        credential = await signInWithFacebook();
        break;
    }
    if (credential == null) {
      return false;
    }
    var user = credential.user;
    if (user != null) {
      await loginWithFirebaseToken(user);
    } else {
      throw Exception("Google Sign-In: Not able to get User.");
    }
    isSignin = false;
    if (lastConnectionState == null) {
      throw Exception("Google Sign-In: Not able to connect with backend");
    }
    return lastConnectionState != null &&
        lastConnectionState!.text != null &&
        lastConnectionState!.text! == "connected";
  }

  Future<UserCredential> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    if (loginResult.accessToken == null) {
      throw Exception("No facebook access token found!");
    }
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    // Once signed in, return the UserCredential
    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential> signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  Future<UserCredential> signInWithGoogle(BuildContext context) async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser =
        await GoogleSignIn(scopes: ['profile', 'email']).signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  isInLibrary(int id) => library.any((element) => element.podcastId == id);

  getLibraryEntries(int amount) {
    if (library.length < amount) {
      amount = library.length;
    }
    return library.take(amount);
  }

  setInitialValues() async {
    prefs = await SharedPreferences.getInstance();
    String secToken = await prefs.getString(TOKEN_IDENTIFIER);
    if (secToken.isNotEmpty) {
      token = secToken;
      print(token);
      baseLogin = true;
    }

    FirebaseAuth.instance.idTokenChanges().listen((User? user) async {
      if (isSignin) {
        return;
      }
      if (user == null && !baseLogin) {
        token = "";
        firebaseToken = "";
        await prefs.setString(TOKEN_IDENTIFIER, "");
      } else if(user != null && !baseLogin) {
        try {
          await loginWithFirebaseToken(user);
        } catch (ex) {
          prefs.setString(TOKEN_IDENTIFIER, "");
        }
      }
    });

  }

  loginWithFirebaseToken(User user) async {
    baseLogin = false;
    var userIdToken = await user.getIdToken(true);
    firebaseToken = userIdToken;
    try {
      lastConnectionState = await UserRepository.firebaseLogin(userIdToken);
      if (lastConnectionState!.data != null &&
          lastConnectionState!.data!.isNotEmpty) {
        token = lastConnectionState!.data!;
        await getCoreData();
      }
    } catch (exception) {
      throw new Exception(
          "Firebase Auth: Error while requesting data from Server");
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
    print("Get Core Data");
    if (token.isNotEmpty) {
      await getUserInfo();
      if (userInfo != null) {
        await getRewards();
        await getLibrary(true);
        await getFriends();
        var lastUpdate = await prefs.getInt(LAST_NOTIFICATION_UPDATE);
        if(lastUpdate != null) {
          lastNotificationSeen = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
        }
      }
      //TODO: Vorschläge basierend auf den Vorzügen des Nutzers laden
    }
    var podcasts = await PodcastRepository.getRandomPodcast(20);
    podcastProposalsHomeScreen[0] = podcasts.take(10).toList();
    podcastProposalsHomeScreen[1] = podcasts.skip(10).take(10).toList();
    podcastProposalsHomeScreen[2] = podcasts.skip(20).take(10).toList();
  }

  getRewards() async {
    rewards = await UserRepository.getUserRewards();
  }

  getFriends() async {
    await friendService.getFriends();
  }

  Future<bool> getUserInfo() async {
    userInfo = await UserRepository.getUserInfo();
    if (userInfo == null || userInfo!.userName == null) {
      logout();
      return false;
    }
    return true;
  }

  //#region Login/Logout
  Future<bool> emailLogin(String email, String pin) async {
    token = await UserRepository.emailLogin(email, pin);
    prefs.setString(TOKEN_IDENTIFIER, token);
    if (token.isNotEmpty) {
      await getCoreData();
      return userInfo != null;
    }
    return false;
  }

  Future<bool> firebaseVerify(String pin) async {
    if (firebaseToken.isEmpty) {
      return false;
    }
    var response = await UserRepository.firebaseVerify(firebaseToken, pin);
    prefs.setString(TOKEN_IDENTIFIER, response.data);
    token = response.data ?? "";
    if (response.data != null && response.data!.isNotEmpty) {
      await getCoreData();
      return userInfo != null;
    }
    return false;
  }

  Future<bool> firebaseRegister(String username, bool newsletter) async {
    if (firebaseToken.isEmpty) {
      return false;
    }
    try {
      var response = await UserRepository.firebaseRegister(
          firebaseToken, username, newsletter);
      prefs.setString(TOKEN_IDENTIFIER, response.data);
      token = response.data ?? "";
      if (response.data != null && response.data!.isNotEmpty) {
        await getCoreData();
        return userInfo != null;
      }
    } catch (ex) {}
    return false;
  }

  logout() async {
    baseLogin = false;
    token = "";
    userInfo = null;
    rewards = Reward();
    library = List.empty();
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    GoogleSignIn googleSignIn = GoogleSignIn();
    FacebookAuth facebookAuth = FacebookAuth.instance;
    try {
      if(googleSignIn.currentUser != null) {
        await googleSignIn.disconnect();
      }
      if(await facebookAuth.accessToken != null) {
        await facebookAuth.logOut();
      }
      await FirebaseAuth.instance.signOut();
    } catch(ex) {

    }
    await prefs.setString(TOKEN_IDENTIFIER, "");
  }
  //#endregion

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
  Future<List<Podcast>> getLibrary(refresh) async {
    if(refresh) {
      var newLibrary = await PodcastRepository.getUserLibrary();
      library = newLibrary;
    }
    for(var entry in library) {
      var lastUpdateSeen = prefs.getInt(LAST_NOTIFICATION_UPDATE + entry.podcastId.toString());
      if(lastUpdateSeen != null) {
        var date = DateTime.fromMillisecondsSinceEpoch(lastUpdateSeen);
        lastPodcastUpdateSeen[entry.podcastId!] = date;
      }
    }
    return library;
  }

  Future<List<Podcast>> removeFromLibrary(int id) async {
    if (await PodcastRepository.removeFromLibrary(id)) {
      library.removeWhere((item) => item.podcastId == id);
    }
    return library;
  }

  Future<List<Podcast>> addToLibrary(int id) async {
    if (await PodcastRepository.addToLibrary(id)) {
      return await getLibrary(true);
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

  void SetLastLibraryNotifcationUpdate() async {
    lastNotificationSeen = DateTime.now().toUtc();
    await prefs.setInt(LAST_NOTIFICATION_UPDATE, lastNotificationSeen!.millisecondsSinceEpoch);
  }

  bool unseenLibraryNotifcationUpdates() {
    if(isConnected && library != null && library.length > 0) {
      for(var entry in library) {
        if(entry.lastUpdate != null
            && entry.lastUpdate!.difference(DateTime.now().toUtc()).inDays < 7) {
          return lastNotificationSeen == null || lastNotificationSeen!.millisecondsSinceEpoch < entry.lastUpdate!.millisecondsSinceEpoch;
        }
      }
    }
    return false;
  }

  bool unseenPodcastNotifcationUpdates(int id) {
    var podcast = library.firstWhereOrNull((element) => id.isEqual(element.podcastId!));
    if(isConnected && library.isNotEmpty && podcast != null && podcast.lastUpdate != null) {
      print(lastPodcastUpdateSeen[id]);
      return !lastPodcastUpdateSeen.containsKey(podcast.podcastId)
        || lastPodcastUpdateSeen[podcast.podcastId]!.millisecondsSinceEpoch < podcast.lastUpdate!.millisecondsSinceEpoch;
    }
    return false;
  }

  Future<void> UpdatePodcastVisitDate(int? id) async {
    if(id == null || !isConnected || library == null || !library.any((element) => id.isEqual(element.podcastId!))) {
      return;
    }
    lastPodcastUpdateSeen[id] = DateTime.now().toUtc();
    await prefs.setInt(LAST_NOTIFICATION_UPDATE + id.toString(), lastPodcastUpdateSeen[id]!.millisecondsSinceEpoch);
  }

  getProposals(int genre) {
    return podcastProposalsHomeScreen[genre];
  }

  //#endregion

}
