import 'dart:io';

import 'package:Talkaboat/screens/app.screen.dart';
import 'package:Talkaboat/screens/onboarding/onboarding.screen.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/themes/colors.dart';
import 'package:Talkaboat/themes/default.theme_new.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: DefaultColors.primaryColor.shade900, // navigation bar color
      statusBarColor: DefaultColors.secondaryColor.shade900 // status bar color
      ));
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

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Talkaboat',
        theme: NewDefaultTheme.defaultTheme,
        debugShowCheckedModeBanner: false,
        home: AnimatedSplashScreen(
            duration: 2000,
            splash: const Image(width: 250, image: AssetImage('assets/images/talkaboat.png')),
            nextScreen: getIt<UserService>().newUser ? const OnBoardingScreen() : const AppScreen(title: 'Talkaboat'),
            splashTransition: SplashTransition.fadeTransition,
            pageTransitionType: PageTransitionType.fade,
            backgroundColor: DefaultColors.secondaryColor.shade900));
  }
}
