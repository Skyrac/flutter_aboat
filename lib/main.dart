import 'package:Talkaboat/themes/default.theme.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:talkaboat/injection/injector.dart';
import 'package:talkaboat/screens/app.screen.dart';
import 'package:talkaboat/services/user/user.service.dart';
import 'package:talkaboat/themes/colors.dart';
import 'package:talkaboat/themes/default.theme.dart';

import 'configuration/dio.config.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor:
          DefaultColors.primaryColor.shade900, // navigation bar color
      statusBarColor: DefaultColors.secondaryColor.shade900 // status bar color
      ));
  CachedNetworkImage.logLevel = CacheManagerLogLevel.debug;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await configureDependencies();
  configDio();

  await getIt<UserService>().getCoreData();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Talkaboat',
        theme: DefaultTheme.defaultTheme,
        debugShowCheckedModeBanner: false,
        home: AnimatedSplashScreen(
            duration: 2000,
            splash: const Image(
                width: 250, image: AssetImage('assets/images/talkaboat.png')),
            nextScreen: const AppScreen(title: 'Talkaboat'),
            splashTransition: SplashTransition.fadeTransition,
            pageTransitionType: PageTransitionType.fade,
            backgroundColor: DefaultColors.secondaryColor.shade900));
  }
}
