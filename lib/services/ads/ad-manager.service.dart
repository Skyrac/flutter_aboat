//android rewarded ad: ca-app-pub-3269278654019042/7737241131

import 'dart:io';

import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  AdManager._();
  static final userService = getIt<UserService>();

  static late RewardedAd? rewardedQuestAd;

  static var callback;

  static var isAdLoading = false;

  static dispose() {
    if(rewardedQuestAd != null) {
      rewardedQuestAd!.dispose();
    }
    rewardedQuestAd = null;
    isAdLoading = false;
    callback = null;
  }

  static Future<AppOpenAd?> loadAppStartAd() async {
    AppOpenAd? appOpenAd;
    final AdRequest request = AdRequest();
    final adLoadCallback = AppOpenAdLoadCallback(
      onAdLoaded: (ad) {
        appOpenAd = ad;
        print('App start ad loaded');
      },
      onAdFailedToLoad: (error) {
        print('App start ad failed to load: $error');
      },
    );

    try {
      await AppOpenAd.load(
        adUnitId: Platform.isIOS ? "ca-app-pub-3269278654019042/4003240837" : "ca-app-pub-3269278654019042/2156926258",
        request: request,
        adLoadCallback: adLoadCallback,
        orientation: AppOpenAd.orientationPortrait,
      );
    } catch (e) {
      print('Error loading app start ad: $e');
    }

    return appOpenAd;
  }

  static preLoadAd(bool show) {
    if(isAdLoading) {
      return;
    }
    isAdLoading = true;
    RewardedAd.load(
        adUnitId: Platform.isIOS ? "ca-app-pub-3269278654019042/9016116482" : "ca-app-pub-3269278654019042/7737241131",
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            isAdLoading = false;
            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            rewardedQuestAd = ad;
            debugPrint("Show ad after loading");
            var username = userService.userInfo?.userName;
            debugPrint(username);
            var options = ServerSideVerificationOptions(userId: username);
            rewardedQuestAd!.setServerSideOptions(options);
            rewardedQuestAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (RewardedAd ad) => debugPrint('$ad onAdShowedFullScreenContent.'),
              onAdDismissedFullScreenContent: (RewardedAd ad) {
                rewardedQuestAd = null;
                preLoadAd(false);
                ad.dispose();
              },
              onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
                debugPrint("$error");

                rewardedQuestAd = null;
                preLoadAd(false);
                if(callback != null) {
                  callback(error.message);
                }
                ad.dispose();
              },
              onAdImpression: (RewardedAd ad) =>
              {
                rewardedQuestAd = null,
                preLoadAd(false),
                FirebaseAnalytics.instance.logAdImpression(adPlatform: "Google AdMob", adFormat: "Rewarded Ad", adUnitName: ad.adUnitId)
            },);
            if(show) {
              rewardedQuestAd!.show(onUserEarnedReward: (AdWithoutView ad,
                  RewardItem rewardItem) {
                FirebaseAnalytics.instance.logAdImpression(
                    adPlatform: "Google AdMob",
                    adFormat: "Rewarded Ad",
                    adUnitName: ad.adUnitId);
                if(callback != null) {
                  callback("");
                }
                // Reward the user for watching an ad.
              });
            }
          },
          onAdFailedToLoad: (LoadAdError error) {
            isAdLoading = false;
    if(callback != null) {
      callback(error.message);
    }
            rewardedQuestAd = null;
            debugPrint("Error Message: ${error.message}");
            debugPrint('RewardedAd failed to load: $error');
          },
        ));
  }

  static showQuestAd(_callback) {
    callback = _callback;
    if(rewardedQuestAd == null) {
      debugPrint("Load and show ad");
      preLoadAd(true);
      return;
    }
    var username = userService.userInfo?.userName;
    var options = ServerSideVerificationOptions(userId: username);
    rewardedQuestAd!.setServerSideOptions(options);

    debugPrint("Show preloaded ad");
    rewardedQuestAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
      preLoadAd(false);
      callback("");
    });
  }

  static void setAdvertismentIdentifier(String uuid) {

  }
}
