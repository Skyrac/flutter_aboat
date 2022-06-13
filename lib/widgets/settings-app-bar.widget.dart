import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:talkaboat/screens/login.screen.dart';

class SettingsAppBarWidget extends StatelessWidget {
  const SettingsAppBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Settings'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            icon: const Icon(Icons.login),
            tooltip: '',
            onPressed: () {
              Navigator.push(
                  context,
                  PageTransition(
                      alignment: Alignment.bottomCenter,
                      curve: Curves.bounceOut,
                      type: PageTransitionType.fade,
                      duration: const Duration(milliseconds: 300),
                      reverseDuration: const Duration(milliseconds: 200),
                      child: LoginScreen()));
            },
          ),
        )
      ],
    );
  }
}
