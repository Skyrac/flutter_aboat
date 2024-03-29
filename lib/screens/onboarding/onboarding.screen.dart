import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/themes/colors.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../login.screen.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();
  void _onIntroEnd(context) async {
    await getIt<UserService>().finishIntroduction();
    await FirebaseAnalytics.instance.logTutorialComplete();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen(false)),
    );
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/$assetName', width: width);
  }

  BuildContext? _context;

  @override
  initState() {
    FirebaseAnalytics.instance.logTutorialBegin();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: DefaultColors.secondaryColorBase, // navigation bar color
        statusBarColor: DefaultColors.secondaryColor.shade900 // status bar color
        ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _context ??= context;
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: DefaultColors.secondaryColorBase,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: DefaultColors.secondaryColorBase,
      globalHeader: Align(
        alignment: Alignment.topRight,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, right: 16),
            child: _buildImage('images/aboat.png', 40),
          ),
        ),
      ),

      pages: [
        PageViewModel(
          title: "Podcasts",
          image: _buildImage('images/intro_podcasts.png'),
          body: AppLocalizations.of(context)!.pageInfo,
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: AppLocalizations.of(context)!.dailyTasks,
          image: _buildImage('images/intro_tasks.png', 225),
          body: AppLocalizations.of(context)!.pageInfo2,
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: AppLocalizations.of(context)!.friends,
          image: _buildImage('images/intro_social.png', 275),
          body: AppLocalizations.of(context)!.pageInfo3,
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: AppLocalizations.of(context)!.cryptocurrency,
          body: AppLocalizations.of(context)!.pageInfo4,
          image: _buildImage('images/intro_crypto.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: AppLocalizations.of(context)!.takeAShare,
          image: _buildImage('images/intro_crypto_social.png'),
          body: AppLocalizations.of(context)!.pageInfo5,
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: false,
      //rtl: true, // Display as right-to-left
      back: const Icon(Icons.arrow_back),
      skip: Text(AppLocalizations.of(context)!.skip, style: const TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: Text(AppLocalizations.of(context)!.done, style: const TextStyle(fontWeight: FontWeight.w600)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }
}
