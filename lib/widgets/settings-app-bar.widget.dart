import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../injection/injector.dart';
import '../screens/login.screen.dart';
import '../services/user/user.service.dart';

class SettingsAppBarWidget extends StatefulWidget {
  const SettingsAppBarWidget({Key? key, this.refreshParent}) : super(key: key);
  final Function? refreshParent;
  @override
  State<SettingsAppBarWidget> createState() => _SettingsAppBarWidgetState();
}

class _SettingsAppBarWidgetState extends State<SettingsAppBarWidget> {
  refresh() {
    if (widget.refreshParent != null) {
      widget.refreshParent!();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final UserService userService = getIt<UserService>();
    return AppBar(
      title: const Text('Settings'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: userService.userInfo != null && userService.userInfo!.userName != null
              ? IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: '',
                  onPressed: () async {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const LoginScreen(
                              false,
                              allowPop: false,
                            )));
                    await userService.logout();
                  },
                )
              : IconButton(
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
                            child: LoginScreen(true, refreshParent: refresh)));
                  },
                ),
        )
      ],
    );
  }
}
