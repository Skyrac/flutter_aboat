import 'dart:io';

import 'package:Talkaboat/screens/app.screen.dart';
import 'package:Talkaboat/screens/login.screen.dart';
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
      systemNavigationBarColor: const Color.fromRGBO(29, 40, 58, 1), // navigation bar color
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

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

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
    print("isConnected ${userService.isConnected}");
    print("guest ${userService.guest}");
    print("token ${userService.token}");
    print("userinfo ${userService.userInfo?.toJson()}");
    final nextScreen = userService.newUser
        ? const OnBoardingScreen()
        : (!userService.isConnected && !userService.guest)
            ? LoginScreen(
                false,
                () => setState(() {
                      print("refresh");
                    }))
            : const AppScreen(title: 'Talkaboat');
    print(nextScreen);
    return MaterialApp(
        title: 'Talkaboat',
        theme: NewDefaultTheme.defaultTheme,
        debugShowCheckedModeBanner: false,
        navigatorObservers: [routeObserver],
        home: AnimatedSplashScreen(
            duration: 2000,
            splash: const Image(width: 250, image: AssetImage('assets/images/talkaboat.png')),
            nextScreen: nextScreen,
            splashTransition: SplashTransition.fadeTransition,
            pageTransitionType: PageTransitionType.fade,
            backgroundColor: DefaultColors.secondaryColor.shade900));
  }
}
