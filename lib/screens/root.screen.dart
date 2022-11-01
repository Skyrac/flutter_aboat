import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/screens/app.screen.dart';
import 'package:Talkaboat/screens/login.screen.dart';
import 'package:Talkaboat/screens/onboarding/onboarding.screen.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:flutter/material.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  final userService = getIt<UserService>();

  @override
  Widget build(BuildContext context) {
    if (userService.newUser) {
      return const OnBoardingScreen();
    }
    if (!userService.isConnected && !userService.guest) {
      return const LoginScreen(false);
    }

    return const AppScreen(title: 'Talkaboat');
  }
}
