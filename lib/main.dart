import 'dart:io';

import 'package:Talkaboat/l10n/l10n.dart';
import 'package:Talkaboat/navigator_keys.dart';
import 'package:Talkaboat/screens/root.screen.dart';
import 'package:Talkaboat/services/ads/ad-manager.service.dart';
import 'package:Talkaboat/services/dynamiclinks/dynamic-links.service.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/themes/colors.dart';
import 'package:Talkaboat/themes/default.theme_new.dart';
import 'package:Talkaboat/utils/common.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'configuration/dio.config.dart';
import 'firebase_options.dart';
import 'injection/injector.dart';

void main() async {
  //runApp(const MaterialApp(home: Agora()));
  //return;
  WidgetsFlutterBinding.ensureInitialized();
  Future.microtask(() async {
    final prefs = await SharedPreferences.getInstance();
    final didEvict = prefs.getBool("evictedCache");
    if (didEvict == null || didEvict == false) {
      await DefaultCacheManager().emptyCache();
      await prefs.setBool("evictedCache", true);
    }
  });
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  ByteData data = await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());
  MobileAds.instance.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAnalytics.instance.logAppOpen();
  await configureDependencies();
  configDio();
  await getIt<UserService>().getCoreData();
  final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
  runApp(MyApp(initialLink: initialLink));
}

class MyApp extends StatefulWidget {
  MyApp({Key? key, this.initialLink}): super(key: key);

  PendingDynamicLinkData? initialLink;
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final userService = getIt<UserService>();
  AppOpenAd? _appOpenAd;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    AdManager.loadAppStartAd().then((ad) => {
      _appOpenAd = ad,
      if(userService.newUser) {
        _appOpenAd?.show(),
        AdManager.loadAppStartAd().then((ad) => _appOpenAd = ad)
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _appOpenAd != null) {
      _appOpenAd?.show();
      _appOpenAd = null;
      AdManager.loadAppStartAd().then((ad) => _appOpenAd = ad);
    } else if(_appOpenAd == null) {
      AdManager.loadAppStartAd().then((ad) => {
        _appOpenAd = ad,
        if(userService.newUser) {
          _appOpenAd?.show(),
          AdManager.loadAppStartAd().then((ad) => _appOpenAd = ad)
        }
      });
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (widget.initialLink != null) {
      DynamicLinkUtils.handleDynamicLink(context, widget.initialLink!);
    }
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      DynamicLinkUtils.handleDynamicLink(context, dynamicLinkData);
    }).onError((error) {
      // Handle errors
    });
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => SelectEpisodePage(),
        )
      ],
      child: MaterialApp(
          navigatorKey: NavigatorKeys.navigatorKeyMain,
          title: 'Talkaboat',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: l10n.all,
          theme: NewDefaultTheme.defaultTheme,
          debugShowCheckedModeBanner: false,
          navigatorObservers: [routeObserver],
          home: AnimatedSplashScreen(
              duration: 2000,
              splash: const Image(width: 250, image: AssetImage('assets/images/talkaboat.png')),
              nextScreen: ChangeNotifierProvider(
                create: (context) => userService,
                  child: const RootScreen()),
              splashTransition: SplashTransition.fadeTransition,
              pageTransitionType: PageTransitionType.fade,
              backgroundColor: DefaultColors.secondaryColor.shade900)),
    );
  }
}
