import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/main.dart';
import 'package:Talkaboat/screens/app.screen.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../login.screen.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> with RouteAware {
  final introKey = GlobalKey<IntroductionScreenState>();
  void _onIntroEnd(context) async {
    await getIt<UserService>().finishIntroduction();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LoginScreen(() => setState(() {}))),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Covering route was popped off the navigator.
    super.didPopNext();
    // didPopNext is still in the context of the pop that triggered it
    // we await till it is computed before our next pop
    Future.delayed(
        Duration.zero,
        () =>
            Navigator.of(_context!).pushReplacement(MaterialPageRoute(builder: (_) => const AppScreen(title: 'Talkaboat'))));
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/$assetName', width: width);
  }

  BuildContext? _context;

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
          body:
              "Enjoy more than 700.000 Podcasts while earning Aboat Token and supporting your favorite podcasters for doing so",
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Daily Tasks",
          image: _buildImage('images/intro_tasks.png', 225),
          body: "Finish your daily tasks to earn great rewards and get an insight into blockchain while helping creators",
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Friends",
          image: _buildImage('images/intro_social.png', 275),
          body: "Add or invite your friends to share your latest news, achievements or your favorite podcast",
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Cryptocurrency",
          body:
              "We help you to take the first step into cryptocurrencies in a secure and fun environment\n\nYou can take it step by step without all the heavy technical details or the need to use money",
          image: _buildImage('images/intro_crypto.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Take a share",
          image: _buildImage('images/intro_crypto_social.png'),
          body:
              "We provide new ways for creators and the community to help each other\n\nOne of this is by buying Non-Fungible Tokens from creators to access income or content rights",
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
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
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
