//android rewarded ad: ca-app-pub-3269278654019042/7737241131

import 'dart:io';

import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  AdManager._();
  static final userService = getIt<UserService>();

  static var rewardedQuestAd;

  static showQuestAd(callback) {
    RewardedAd.load(adUnitId: Platform.isIOS ? "ca-app-pub-3269278654019042/9016116482" : "ca-app-pub-3269278654019042/7737241131",
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
      onAdLoaded: (RewardedAd ad) {
        print('$ad loaded.');
        // Keep a reference to the ad so you can show it later.
        rewardedQuestAd = ad;
        rewardedQuestAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (RewardedAd ad) =>
              print('$ad onAdShowedFullScreenContent.'),
          onAdDismissedFullScreenContent: (RewardedAd ad) {
            ad.dispose();
          },
          onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
            ad.dispose();
          },
          onAdImpression: (RewardedAd ad) => print('$ad impression occurred.'),
        );
        var username = userService.userInfo?.userName;
        var options = ServerSideVerificationOptions(userId: userService.userInfo?.userName);
        rewardedQuestAd.setServerSideOptions(options);
        rewardedQuestAd.show(onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
          callback();
          // Reward the user for watching an ad.
        });
      },
      onAdFailedToLoad: (LoadAdError error) {
        print('RewardedAd failed to load: $error');
      },
    ));

  }
}