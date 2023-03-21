import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBannerWidget extends StatefulWidget {
  @override
  _AdBannerWidgetState createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;


  BannerAd _createBannerAd() {
    return BannerAd(
      adUnitId: Platform.isIOS ? 'ca-app-pub-3269278654019042/3712430944' : 'ca-app-pub-3269278654019042/8932133885',
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('Ad loaded: ${ad.adUnitId}');
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Ad failed to load: ${ad.adUnitId}, $error');

          debugPrint("DISPOSE DUE TO AD LOAD FAIL BANNER AD");
          ad.dispose();
        },
        onAdOpened: (Ad ad) {
          print('Ad opened: ${ad.adUnitId}');
        },
        onAdClosed: (Ad ad) {
          print('Ad closed: ${ad.adUnitId}');

          debugPrint("DISPOSE DUE TO AD CLOSE BANNER AD");
          ad.dispose();
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _bannerAd = _createBannerAd();
    _bannerAd?.load();
    debugPrint("LOADING BANNER AD");
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: _isAdLoaded,
      child: AdWidget(ad: _bannerAd!),
      replacement: Container(),
    );
  }
}