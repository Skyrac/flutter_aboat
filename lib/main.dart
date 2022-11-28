import 'dart:io';

import 'package:Talkaboat/l10n/l10n.dart';
import 'package:Talkaboat/screens/root.screen.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/themes/colors.dart';
import 'package:Talkaboat/themes/default.theme_new.dart';
import 'package:Talkaboat/utils/common.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:page_transition/page_transition.dart';

import 'configuration/dio.config.dart';
import 'firebase_options.dart';
import 'injection/injector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  await configureDependencies();
  configDio();
  await getIt<UserService>().getCoreData();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final userService = getIt<UserService>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Talkaboat',
        localizationsDelegates: [
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
            nextScreen: const RootScreen(),
            splashTransition: SplashTransition.fadeTransition,
            pageTransitionType: PageTransitionType.fade,
            backgroundColor: DefaultColors.secondaryColor.shade900));
  }
}
