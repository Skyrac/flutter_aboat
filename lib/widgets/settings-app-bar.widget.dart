import 'package:Talkaboat/navigator_keys.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      title: Text(AppLocalizations.of(context)!.settings),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: userService.userInfo != null && userService.userInfo!.userName != null
              ? IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: '',
                  onPressed: () async {
                    await userService.logout();
                    NavigatorKeys.navigatorKeyMain.currentState!.push(PageTransition(
                        alignment: Alignment.bottomCenter,
                        curve: Curves.bounceOut,
                        type: PageTransitionType.fade,
                        duration: const Duration(milliseconds: 300),
                        reverseDuration: const Duration(milliseconds: 200),
                        child: LoginScreen(true, refreshParent: refresh)));
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.login),
                  tooltip: '',
                  onPressed: () {
                    NavigatorKeys.navigatorKeyMain.currentState!.push(PageTransition(
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
