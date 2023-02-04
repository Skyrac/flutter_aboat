import 'dart:convert';
import 'dart:math';

import 'package:Talkaboat/models/rewards/reward.model.dart';
import 'package:Talkaboat/models/stormm/stormm-mission.model.dart';
import 'package:Talkaboat/services/hubs/chat/chat.service.dart';
import 'package:Talkaboat/services/user/reward.service.dart';
import 'package:Talkaboat/services/user/social.service.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../injection/injector.dart';
import '../../models/playlist/playlist.model.dart';
import '../../models/podcasts/podcast.model.dart';
import '../../models/response.model.dart';
import '../../models/user/user-info-model.dart';
import '../hubs/reward/reward-hub.service.dart';
import '../repositories/podcast.repository.dart';
import '../repositories/stormm.repository.dart';
import '../repositories/user.repository.dart';

enum SocialLogin { Google, Facebook, Apple }

class UserService {
  bool newUser = true;
  bool _guest = false;
  String token = "";
  String firebaseToken = "";
  UserInfoData? userInfo;
  List<Podcast> favorites = List.empty();
  List<Playlist> playlists = List.empty();
  Map<int, List<Podcast>> podcastProposalsHomeScreen = {};
  ResponseModel? lastConnectionState;
  DateTime? lastNotificationSeen;
  final friendService = getIt<SocialService>();
  Map<int, DateTime?> lastPodcastUpdateSeen = {};
  late final SharedPreferences prefs;
  var isSignin = false;
  var baseLogin = false;
  static const String TOKEN_IDENTIFIER = "aboat_token";
  static const String LAST_NOTIFICATION_UPDATE = "last_update_seen";

  get isConnected => token.isNotEmpty && userInfo != null;
  get guest => _guest;

  final rewardService = getIt<RewardService>();
  get availableToken => rewardService.value.vested;
  get lockedToken => rewardService.value.unvested;

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
        credential = await signInWithApple();
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
    debugPrint("lastConnectionState: ${lastConnectionState?.toJson()}");
    return lastConnectionState != null && lastConnectionState!.text != null && lastConnectionState!.text! == "connected";
  }

  Future<UserCredential> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    if (loginResult.accessToken == null) {
      throw Exception("No facebook access token found!");
    }
    final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);

    // Once signed in, return the UserCredential
    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
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
    debugPrint("$oauthCredential");
    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  Future<UserCredential> signInWithGoogle(BuildContext context) async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn(scopes: ['profile', 'email']).signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  isInFavorites(int? id) => userInfo != null && id != null && favorites.any((element) => element.podcastId == id);

  getFavoritesEntries(int amount) {
    if (favorites.length < amount) {
      amount = favorites.length;
    }
    return favorites.take(amount);
  }

  finishIntroduction() async {
    newUser = false;
    await prefs.setBool('newUser', false);
  }

  loginAsGuest() async {
    _guest = true;
  }

  setInitialValues() async {
    prefs = await SharedPreferences.getInstance();
    newUser = prefs.getBool('newUser') ?? true;
    String secToken = prefs.getString(TOKEN_IDENTIFIER) ?? "";
    if (secToken.isNotEmpty) {
      token = secToken;
      debugPrint(token);
      baseLogin = true;
    }

    try {
      FirebaseAuth.instance.idTokenChanges().listen((User? user) async {
        if (isSignin) {
          return;
        }
        if (user == null && !baseLogin) {
          token = "";
          firebaseToken = "";
          await prefs.setString(TOKEN_IDENTIFIER, "");
        } else if (user != null && !baseLogin) {
          try {
            await loginWithFirebaseToken(user);
          } catch (ex) {
            prefs.setString(TOKEN_IDENTIFIER, "");
          }
        }
      });
    } catch (exception) {
      throw Exception("Firebase Auth: loggin in $exception");
    }
  }

  loginWithFirebaseToken(User user) async {
    baseLogin = false;
    var userIdToken = await user.getIdToken(true);
    firebaseToken = userIdToken;
    try {
      lastConnectionState = await UserRepository.firebaseLogin(userIdToken);
      if (lastConnectionState!.data != null && lastConnectionState!.data!.isNotEmpty) {
        token = lastConnectionState!.data!;
        await getCoreData();
      }
    } catch (exception) {
      throw Exception("Firebase Auth: Error while requesting data from Server $exception");
    }
  }

  static Future<UserService> init() async {
    var userService = UserService();
    await userService.setInitialValues();
    return userService;
  }

  getCoreData() async {
    debugPrint("Get Core Data");
    if (token.isNotEmpty) {
      await getUserInfo();
      Future.microtask(() => getIt<RewardHubService>().connect());
      Future.microtask(() => getIt<ChatService>().connect());
      if (userInfo != null) {
        debugPrint("$userInfo");
        _guest = false;
        await rewardService.getRewards();
        await getFavorites(refresh: true);
        await getFriends();
        var lastUpdate = prefs.getInt(LAST_NOTIFICATION_UPDATE);
        if (lastUpdate != null) {
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

  getFriends() async {
    await friendService.initialize();
  }

  Future<bool> getUserInfo() async {
    debugPrint("Get User Info");
    userInfo = await UserRepository.getUserInfo();
    userInfo!.userId = int.parse(Jwt.parseJwt(token)["primarysid"]);
    if (userInfo == null || userInfo!.userName == null) {
      logout();
      return false;
    }
    return true;
  }

  Future<String?> emailRegister(String email, String pin, String username, bool newsletter) async {
    try {
      var response = await UserRepository.emailRegister(email, pin, username, newsletter);
      debugPrint("response ${response.toJson()}");
      if (response.data == null || response.data!.isEmpty) {
        return response.text ?? "false";
      }
      token = response.data ?? "";
      prefs.setString(TOKEN_IDENTIFIER, token);
      if (token.isNotEmpty) {
        await getCoreData();
        return userInfo != null ? null : "false";
      }
      return "false";
    } catch (_) {
      return "false";
    }
  }

  //#region Login/Logout
  Future<String> emailLogin(String email, String pin) async {
    token = await UserRepository.emailLogin(email, pin);
    if (token == "new_account") {
      return "new_account";
    }
    if (token.isEmpty) {
      return "false";
    }
    prefs.setString(TOKEN_IDENTIFIER, token);
    if (token.isNotEmpty) {
      await getCoreData();
      return userInfo != null ? "true" : "false";
    }
    return "false";
  }

  Future<bool> firebaseVerify(String pin) async {
    if (firebaseToken.isEmpty) {
      return false;
    }
    var response = await UserRepository.firebaseVerify(firebaseToken, pin);
    token = response.data ?? "";
    prefs.setString(TOKEN_IDENTIFIER, token);
    if (response.data != null && response.data!.isNotEmpty) {
      await getCoreData();
      return userInfo != null;
    }
    return false;
  }

  Future<String?> firebaseRegister(String username, bool newsletter) async {
    try {
      var response = await UserRepository.firebaseRegister(firebaseToken, username, newsletter);
      if (response.data == null || response.data!.isEmpty) {
        return response.text ?? "false";
      }
      token = response.data ?? "";
      prefs.setString(TOKEN_IDENTIFIER, token);
      debugPrint("token: $token");

      if (token.isNotEmpty) {
        await getCoreData();
        return userInfo != null ? null : "false";
      }
      return "false";
    } catch (ex) {
      return "false";
    }
  }

  logout() async {
    await getIt<RewardHubService>().disconnect();
    baseLogin = false;
    token = "";
    userInfo = null;
    rewardService.Update(Reward());
    favorites = List.empty();
    GoogleSignIn googleSignIn = GoogleSignIn();
    FacebookAuth facebookAuth = FacebookAuth.instance;
    try {
      if (googleSignIn.currentUser != null) {
        await googleSignIn.disconnect();
      }
      if (await facebookAuth.accessToken != null) {
        await facebookAuth.logOut();
      }
      await FirebaseAuth.instance.signOut();
    } catch (ex) {
      debugPrint("$ex");
    }
    await prefs.setString(TOKEN_IDENTIFIER, "");
  }
  //#endregion

  //#region Playlist
  Future<List<Playlist>> getPlaylists() async {
    var newPlaylists = await PodcastRepository.getPlaylists();
    for (final playlist in newPlaylists) {
      playlist.tracks!.sort((trackA, trackB) => trackA.position!.compareTo(trackB.position!));
    }
    playlists = newPlaylists;
    return newPlaylists;
  }

  Future<Playlist> changePlaylistPosition(int podcastId, int trackId, int position) async {
    var newPlaylist = await PodcastRepository.changeEpisodePositionInPlaylist(podcastId, trackId, position);
    var playlist = playlists[playlists.indexWhere((element) => element.playlistId == newPlaylist.playlistId)];
    playlist.tracks!.sort((trackA, trackB) => trackA.position!.compareTo(trackB.position!));
    playlist.tracks = newPlaylist.tracks;
    return playlist;
  }

  Future<Playlist> removeFromPlaylistByTrackId(int playlistId, int playlistTrackId) async {
    var newPlaylist = await PodcastRepository.removeEpisodeFromPlaylist(playlistId, playlistTrackId);
    var playlist = playlists[playlists.indexWhere((element) => element.playlistId == newPlaylist.playlistId)];
    playlist.tracks!.sort((trackA, trackB) => trackA.position!.compareTo(trackB.position!));
    playlist.tracks = newPlaylist.tracks;
    return playlist;
  }

  Future<Playlist> removeFromPlaylistByEpisodeId(int playlistId, int episodeId) async {
    var playlist = playlists[playlists.indexWhere((element) => element.playlistId == playlistId)];
    var track = playlist.tracks?.firstWhere((element) => element.episodeId == episodeId);
    if (track == null) {
      return playlist;
    }
    var newPlaylist = await PodcastRepository.removeEpisodeFromPlaylist(playlistId, track.playlistTrackId!);

    playlist.tracks!.sort((trackA, trackB) => trackA.position!.compareTo(trackB.position!));
    playlist.tracks = newPlaylist.tracks;
    return playlist;
  }

  Future<Playlist> addToPlaylist(int playlistId, int episodeId) async {
    var newPlaylist = await PodcastRepository.addToPlaylist(playlistId, episodeId);
    var playlist = playlists[playlists.indexWhere((element) => element.playlistId == newPlaylist.playlistId)];
    playlist.tracks!.sort((trackA, trackB) => trackA.position!.compareTo(trackB.position!));
    playlist.tracks = newPlaylist.tracks;
    return playlist;
  }
  //#endregion

  //#region Favorites
  Future<List<Podcast>> getFavorites({refresh = false}) async {
    try {
      if (refresh) {
        var newFavorites = await PodcastRepository.getUserFavorites();
        favorites = newFavorites;
      }
      for (var entry in favorites) {
        var lastUpdateSeen = prefs.getInt(LAST_NOTIFICATION_UPDATE + entry.podcastId.toString());
        if (lastUpdateSeen != null) {
          var date = DateTime.fromMillisecondsSinceEpoch(lastUpdateSeen);
          lastPodcastUpdateSeen[entry.podcastId!] = date;
        }
      }
      return favorites;
    } catch (e) {
      debugPrint("$e");
      return List.empty();
    }
  }

  Future<List<Podcast>> removeFromFavorites(int id) async {
    if (await PodcastRepository.removeFromFavorites(id)) {
      favorites.removeWhere((item) => item.podcastId == id);
    }
    return favorites;
  }

  Future<List<Podcast>> addToFavorites(int id) async {
    if (await PodcastRepository.addToFavorites(id)) {
      return await getFavorites(refresh: true);
    }
    return favorites;
  }

  Future<List<Podcast>> toggleFavoritesEntry(id) async {
    if (isInFavorites(id)) {
      return await removeFromFavorites(id);
    }
    return await addToFavorites(id);
  }

  Future<bool> createPlaylist(String text) async {
    if (text.isEmpty) {
      return false;
    }
    var newPlaylist = await PodcastRepository.createPlaylist(text);
    if (newPlaylist.name != null &&
        newPlaylist.name!.isNotEmpty &&
        !playlists.any((playlist) => playlist.playlistId == newPlaylist.playlistId)) {
      playlists.add(newPlaylist);
      return true;
    }
    return false;
  }

  Future<bool> copyPlaylist(Playlist playlist) async {
    //var newPlaylist = await PodcastRepository.createPlaylist("${playlist.name} - Copy", tracks: playlist.tracks);
    //if (newPlaylist.name != null &&
    //    newPlaylist.name!.isNotEmpty &&
    //    !playlists.any((playlist) => playlist.playlistId == newPlaylist.playlistId)) {
    //  playlists.add(newPlaylist);
    //  return true;
    //}
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

  void SetLastFavoritesNotifcationUpdate() async {
    lastNotificationSeen = DateTime.now().toUtc();
    await prefs.setInt(LAST_NOTIFICATION_UPDATE, lastNotificationSeen!.millisecondsSinceEpoch);
  }

  bool unseenFavoritesNotifcationUpdates() {
    if (isConnected) {
      for (var entry in favorites) {
        if (entry.lastUpdate != null && entry.lastUpdate!.difference(DateTime.now().toUtc()).inDays < 7) {
          return lastNotificationSeen == null ||
              lastNotificationSeen!.millisecondsSinceEpoch < entry.lastUpdate!.millisecondsSinceEpoch;
        }
      }
    }
    return false;
  }

  bool unseenPodcastNotifcationUpdates(int id) {
    var podcast = favorites.firstWhereOrNull((element) => id.isEqual(element.podcastId!));
    if (isConnected && favorites.isNotEmpty && podcast != null && podcast.lastUpdate != null) {
      debugPrint("${lastPodcastUpdateSeen[id]}");
      return !lastPodcastUpdateSeen.containsKey(podcast.podcastId) ||
          lastPodcastUpdateSeen[podcast.podcastId]!.millisecondsSinceEpoch < podcast.lastUpdate!.millisecondsSinceEpoch;
    }
    return false;
  }

  Future<void> UpdatePodcastVisitDate(int? id) async {
    if (id == null || !isConnected || !favorites.any((element) => id.isEqual(element.podcastId!))) {
      return;
    }
    lastPodcastUpdateSeen[id] = DateTime.now().toUtc();
    await prefs.setInt(LAST_NOTIFICATION_UPDATE + id.toString(), lastPodcastUpdateSeen[id]!.millisecondsSinceEpoch);
  }

  getProposals(int genre) {
    return podcastProposalsHomeScreen[genre];
  }

  deleteAccount() async {
    final success = await UserRepository.deleteAccount();
    if (success) {
      logout();
    }
    return success;
  }

  deleteWallet(String address) async {
    final success = await UserRepository.deleteWallet(address);
    if (success) {
      debugPrint("$address deleted");
    }
    return success;
  }

  addWallet(String address) async {
    return await UserRepository.addWallet(address);
  }

  addWalletConfirm(String address, String signature, bool newsletter, String guid) async {
    return await UserRepository.addWalletConfirm(address, signature, newsletter, guid);
  }

  Future<ResponseModel?> getWalletAddRequestCode() async {
    return await UserRepository.getWalletAddRequestCode();
  }

  claimABOAT(int chainId, String address, double amount) async {
    try {
      return await UserRepository.claimABOAT(chainId, address, amount);
    } catch (exception) {
      debugPrint(exception.toString());
    }
  }

  claimABOATNative(int chainId, String address, double amount) async {
    try {
      return await UserRepository.claimABOATNative(chainId, address, amount);
    } catch (exception) {
      debugPrint(exception.toString());
    }
  }

  Future<List<StormmMission>> getStormmMissions() async {
    return await StormmRepository.getStormmMissions();
  }
  //#endregion
}
