import 'package:Talkaboat/navigator_keys.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../screens/login.screen.dart';

class LoginButton extends StatefulWidget {
  const LoginButton({super.key});
  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
        onPressed: (() {
          NavigatorKeys.navigatorKeyMain.currentState!.push(PageTransition(
              alignment: Alignment.bottomCenter,
              curve: Curves.bounceOut,
              type: PageTransitionType.fade,
              duration: const Duration(milliseconds: 300),
              reverseDuration: const Duration(milliseconds: 200),
              child: LoginScreen(true, refreshParent: () => setState(() {}))));
        }),
        child: Container(
            width: 250,
            height: 40,
            decoration: BoxDecoration(
                color: const Color.fromRGBO(99, 163, 253, 1),
                border: Border.all(color: const Color.fromRGBO(188, 140, 75, 0.25)),
                borderRadius: BorderRadius.circular(15)),
            child: Center(
                child: Text("Login",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: const Color.fromRGBO(15, 23, 41, 1), fontWeight: FontWeight.w600)))));
  }
}
