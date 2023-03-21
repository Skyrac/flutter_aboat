import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeAdWidget extends StatefulWidget {
  @override
  _NativeAdWidgetState createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _createNativeAd();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  Future<void> _createNativeAd() async {
    _nativeAd = NativeAd(
      adUnitId: Platform.isIOS ? 'ca-app-pub-3269278654019042/7329625217' : 'ca-app-pub-3269278654019042/8555895214',
      request: AdRequest(),
      factoryId: 'adFactoryExample',
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          print('Native ad loaded: ${ad.adUnitId}');
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Native ad failed to load: ${ad.adUnitId}, $error');
          ad.dispose();
        },
      ),
    );
    await _nativeAd?.load();
  }

  @override
  Widget build(BuildContext context) {
    return _isAdLoaded ? AdWidget(ad: _nativeAd!) : Container();
  }
}