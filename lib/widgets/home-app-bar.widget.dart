import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../screens/settings/settings.screen.dart';

class HomeAppBarWidget extends StatelessWidget {
  const HomeAppBarWidget({Key? key, this.refresh}) : super(key: key);
  final Function? refresh;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Good morning'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '',
            onPressed: () {
              Navigator.push(
                  context,
                  PageTransition(
                      alignment: Alignment.bottomCenter,
                      curve: Curves.bounceOut,
                      type: PageTransitionType.rightToLeftWithFade,
                      duration: const Duration(milliseconds: 500),
                      reverseDuration: const Duration(milliseconds: 500),
                      child: SettingsScreen(refresh: refresh)));
            },
          ),
        )
      ],
    );
  }
}
