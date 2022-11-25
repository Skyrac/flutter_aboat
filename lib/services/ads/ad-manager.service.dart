//android rewarded ad: ca-app-pub-3269278654019042/7737241131

import 'dart:io';

import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  AdManager._();
  static final userService = getIt<UserService>();

  static var rewardedQuestAd;

  static showQuestAd(callback) {
    RewardedAd.load(
        adUnitId: Platform.isIOS ? "ca-app-pub-3269278654019042/9016116482" : "ca-app-pub-3269278654019042/7737241131",
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            rewardedQuestAd = ad;
            rewardedQuestAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (RewardedAd ad) => debugPrint('$ad onAdShowedFullScreenContent.'),
              onAdDismissedFullScreenContent: (RewardedAd ad) {
                ad.dispose();
              },
              onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
                debugPrint("$error");
                callback(error.message);
                ad.dispose();
              },
              onAdImpression: (RewardedAd ad) => debugPrint('$ad impression occurred.'),
            );
            var username = userService.userInfo?.userName;
            debugPrint(username);
            var options = ServerSideVerificationOptions(userId: username);
            rewardedQuestAd.setServerSideOptions(options);
            rewardedQuestAd.show(onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
              callback("");
              // Reward the user for watching an ad.
            });
          },
          onAdFailedToLoad: (LoadAdError error) {
            callback(error.message);
            debugPrint("Error Message: ${error.message}");
            debugPrint('RewardedAd failed to load: $error');
          },
        ));
  }
}
