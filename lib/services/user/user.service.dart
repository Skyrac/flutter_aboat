import 'dart:convert';
import 'dart:math';

import 'package:Talkaboat/models/rewards/reward.model.dart';
import 'package:Talkaboat/models/stormm/stormm-mission.model.dart';
import 'package:Talkaboat/services/dynamiclinks/dynamic-links.service.dart';
import 'package:Talkaboat/services/hubs/chat/chat.service.dart';
import 'package:Talkaboat/services/user/reward.service.dart';
import 'package:Talkaboat/services/user/social.service.dart';
import 'package:Talkaboat/services/user/store.service.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tweet_ui/models/api/v2/tweet_v2.dart';

import '../../injection/injector.dart';
import '../../models/playlist/playlist.model.dart';
import '../../models/podcasts/podcast.model.dart';
import '../../models/response.model.dart';
import '../../models/user/user-info-model.dart';
import '../../utils/preference-keys.const.dart';
import '../device/connection-state.service.dart';
import '../hubs/reward/reward-hub.service.dart';
import '../repositories/podcast.repository.dart';
import '../repositories/social-media.repository.dart';
import '../repositories/stormm.repository.dart';
import '../repositories/user.repository.dart';

enum SocialLogin { Google, Facebook, Apple }

enum ContentViews {
  Podcasts,
  Videos
}

extension ContentViewsExtension on ContentViews {
  String get value {
    switch (this) {
      case ContentViews.Podcasts: return "Podcasts";
      case ContentViews.Videos: return "Videos";
      default: return "";
    }
  }
}

class CurrentContentData {
  final IconData icon;
  final ContentViews label;
  final Color color;

  CurrentContentData({required this.icon, required this.label, required this.color});
}
class UserService extends ChangeNotifier {
  final List<CurrentContentData> menuItems = [
    CurrentContentData(icon: Icons.mic, label: ContentViews.Podcasts, color: Colors.purple),
    CurrentContentData(icon: Icons.video_collection, label: ContentViews.Videos, color: Colors.red),
  ];


  late CurrentContentData currentView = menuItems[0];
  final store = getIt<StoreService>();
  final connectionState = getIt<ConnectionStateService>();
  bool newUser = true;
  bool _guest = false;
  String token = "";
  String? selectedLanguage;
  String firebaseToken = "";
  UserInfoData? userInfo;
  List<Podcast> favorites = List.empty();
  List<Playlist> playlists = List.empty();
  Map<int, List<Podcast>> podcastProposalsHomeScreen = {};
  ResponseModel? lastConnectionState;
  DateTime? lastNotificationSeen;
  final friendService = getIt<SocialService>();
  Map<int, DateTime?> lastPodcastUpdateSeen = {};
  var isSignin = false;
  var baseLogin = false;
  get isConnected => token.isNotEmpty && userInfo != null;
  get guest => _guest;


  final rewardService = getIt<RewardService>();
  get availableToken => rewardService.value.vested;
  get lockedToken => rewardService.value.unvested;

  void changeSelectedView(CurrentContentData newView) {
    currentView = newView;
    notifyListeners();
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
    await store.set(PreferenceKeys.newUser, false);
  }

  loginAsGuest() async {
    _guest = true;
  }

  setInitialValues() async {
    currentView = menuItems[0];
    newUser = await store.get(PreferenceKeys.newUser, true);
    String secToken = await store.get(PreferenceKeys.tokenIdentifier, "");
    if (secToken.isNotEmpty) {
      token = secToken;
      debugPrint(token);
      baseLogin = true;
    } else {
      await getCoreData();
    }

    try {
      FirebaseAuth.instance.idTokenChanges().listen((User? user) async {
        if (isSignin) {
          return;
        }
        if (user == null && !baseLogin) {
          token = "";
          firebaseToken = "";

          //await store.set(PreferenceKeys.tokenIdentifier, "");
        } else if (user != null && !baseLogin) {
          try {
            await loginWithFirebaseToken(user);
          } catch (ex) {
            //await store.set(PreferenceKeys.tokenIdentifier, "");
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
    await userService.connectionState.checkInitialConnection();
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
        var lastUpdate = await store.get(PreferenceKeys.lastNotificationUpdate, 0);
        if (lastUpdate != null) {
          lastNotificationSeen = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
        }
      }
      //TODO: Vorschläge basierend auf den Vorzügen des Nutzers laden
    }
    if(currentView.label == 'Podcasts' && connectionState.isConnected) {
      var podcasts = await PodcastRepository.getRandomPodcast(30, '');
      debugPrint("$podcasts");
      podcastProposalsHomeScreen[0] = podcasts.take(10).toList();
      podcastProposalsHomeScreen[1] = podcasts.skip(10).take(10).toList();
      podcastProposalsHomeScreen[2] = podcasts.skip(20).take(10).toList();
    }
  }

  getFriends() async {
    await friendService.initialize();
  }

  Future<bool> getUserInfo() async {
    if(connectionState.isConnected) {
      userInfo = await UserRepository.getUserInfo();
      userInfo!.userId = int.parse(Jwt.parseJwt(token)["nameid"]);
      store.set(PreferenceKeys.user, jsonEncode(userInfo));
    } else {
      final userInfoRaw = await store.get(PreferenceKeys.user, "");
      if(userInfoRaw != "") {
        userInfo = UserInfoData.fromJson(jsonDecode(userInfoRaw));
      }
    }
    if (userInfo == null || userInfo!.userName == null) {
      return false;
    }

    await FirebaseAnalytics.instance.setUserId(id: "${userInfo!.userId}");
    return true;
  }

  Future<String?> emailRegister(String email, String pin, String username, bool newsletter) async {
    try {
      var response = await UserRepository.emailRegister(email, pin, username, newsletter, await store.get(DynamicLinkUtils.REFERAL_QUERY_PARAM, ""));
      debugPrint("response ${response.toJson()}");
      if (response.data == null || response.data!.isEmpty) {
        return response.text ?? "false";
      }
      token = response.data ?? "";

      await store.set(PreferenceKeys.tokenIdentifier, token);
      await FirebaseAnalytics.instance.logSignUp(signUpMethod: "Email");
      if (token.isNotEmpty) {

        await FirebaseAnalytics.instance.logLogin(loginMethod: "Email");
        await getCoreData();
        return userInfo != null ? null : "false";
      }
      return "false";
    } catch (_) {
      return "false";
    }
  }


  Future<List<TweetV2Response>> getNews() async {
    return await SocialMediaRepository.getNews();
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

    await store.set(PreferenceKeys.tokenIdentifier, token);
    if (token.isNotEmpty) {
      await getCoreData();
      await FirebaseAnalytics.instance.logLogin(loginMethod: "Email");
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
    await store.set(PreferenceKeys.tokenIdentifier, token);
    if (response.data != null && response.data!.isNotEmpty) {

      await FirebaseAnalytics.instance.logLogin(loginMethod: "Firebase");
      await getCoreData();
      return userInfo != null;
    }
    return false;
  }

  Future<String?> firebaseRegister(String username, bool newsletter) async {
    try {
      var response = await UserRepository.firebaseRegister(firebaseToken, username, newsletter, await store.get(DynamicLinkUtils.REFERAL_QUERY_PARAM, ""));
      if (response.data == null || response.data!.isEmpty) {
        return response.text ?? "false";
      }
      token = response.data ?? "";
      await store.set(PreferenceKeys.tokenIdentifier, token);
      debugPrint("token: $token");

      await FirebaseAnalytics.instance.logSignUp(signUpMethod: "Firebase");
      if (token.isNotEmpty) {

        await FirebaseAnalytics.instance.logLogin(loginMethod: "Firebase");
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
    await store.set(PreferenceKeys.tokenIdentifier, "");
  }
  //#endregion

  //#region Playlist
  Future<List<Playlist>> getPlaylists() async {
    List<Playlist> newPlaylists = List<Playlist>.empty();
    if(connectionState.isConnected) {
      newPlaylists = await PodcastRepository.getPlaylists();
      await store.set(PreferenceKeys.playlists, jsonEncode(newPlaylists));
    } else {
      final playlistsRaw = await store.get(PreferenceKeys.playlists, jsonEncode(newPlaylists));
      newPlaylists = List<Playlist>.from((jsonDecode(playlistsRaw) as List<dynamic>)
          .map((dynamic item) => Playlist.fromJson(item)));
    }
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
        List<Podcast> newFavorites = List<Podcast>.empty();
        if(connectionState.isConnected) {
          newFavorites = await PodcastRepository.getUserFavorites();
          await store.set(PreferenceKeys.favorites, jsonEncode(newFavorites));
        } else {
          final favoritesRaw = await store.get(PreferenceKeys.favorites, jsonEncode(newFavorites));
          newFavorites = List<Podcast>.from((jsonDecode(favoritesRaw) as List<dynamic>)
              .map((dynamic item) => Podcast.fromJson(item)));
        }
        favorites = newFavorites;
      }
      for (var entry in favorites) {
        var lastUpdateSeen = await store.get(PreferenceKeys.lastNotificationUpdate + entry.podcastId.toString(), 0);
        if(await store.get("${PreferenceKeys.podcastDetails}${entry.podcastId}", "") == "") {
          await store.set("${PreferenceKeys.podcastDetails}${entry.podcastId}", jsonEncode(entry));
        }
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

  Future<List<Podcast>> removePodcastsFromFavorites(int id) async {
    if (await PodcastRepository.removeFromFavorites(id)) {
      await store.remove("${PreferenceKeys.podcastDetails}${id}");
      favorites.removeWhere((item) => item.podcastId == id);
    }
    return favorites;
  }

  Future<List<Podcast>> addPodcastsToFavorites(int id) async {
    if (await PodcastRepository.addToFavorites(id)) {

      var podcastDetails = await PodcastRepository.getPodcastDetails(id, "asc", 1, 0);
      await store.set("${PreferenceKeys.podcastDetails}${id}", jsonEncode(podcastDetails.toJson()));
      return await getFavorites(refresh: true);
    }
    return favorites;
  }

  Future<List<Podcast>> toggleFavoritesEntry(id) async {
    if (isInFavorites(id)) {
      return await removePodcastsFromFavorites(id);
    }
    return await addPodcastsToFavorites(id);
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
    await store.set(PreferenceKeys.lastNotificationUpdate, lastNotificationSeen!.millisecondsSinceEpoch);
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
    await FirebaseAnalytics.instance.logSelectContent(contentType: "Podcast", itemId: "$id");
    if (id == null || !isConnected || !favorites.any((element) => id.isEqual(element.podcastId!))) {
      return;
    }
    lastPodcastUpdateSeen[id] = DateTime.now().toUtc();
    await store.set(PreferenceKeys.lastNotificationUpdate + id.toString(), lastPodcastUpdateSeen[id]!.millisecondsSinceEpoch);
  }

  getProposals(int genre) {
    debugPrint("$genre");
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
      final result = await UserRepository.claimABOAT(chainId, address, amount);
      if(result) {
        await FirebaseAnalytics.instance.logSpendVirtualCurrency(itemName: "Claim", virtualCurrencyName: "ABOAT", value: amount);
      }
      return result;
    } catch (exception) {
      debugPrint(exception.toString());
    }
  }

  claimABOATNative(int chainId, String address, double amount) async {
    try {
      final result = await UserRepository.claimABOATNative(chainId, address, amount);
      if(result) {
        await FirebaseAnalytics.instance.logSpendVirtualCurrency(itemName: "Claim Native", virtualCurrencyName: "ABOAT", value: amount);
      }
    } catch (exception) {
      debugPrint(exception.toString());
    }
  }

  Future<List<StormmMission>> getStormmMissions() async {
    return await StormmRepository.getStormmMissions();
  }
  //#endregion
}
