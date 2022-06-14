import 'package:flutter/material.dart';

import '../injection/injector.dart';
import '../services/user/user.service.dart';
import '../themes/colors.dart';
import '../widgets/settings-app-bar.widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserService userService = getIt<UserService>();

  refresh() {
    setState(() {});
  }

  Widget getUserCard() {
    return userService.userInfo == null ||
            userService.userInfo!.userName == null
        ? const SizedBox()
        : ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Card(
                child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.verified_user,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          userService.userInfo!.userName!,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          "Cabin Boy",
                          style: Theme.of(context).textTheme.labelMedium,
                        )
                      ],
                    ),
                  )
                ],
              ),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        DefaultColors.primaryColor.shade900,
        DefaultColors.secondaryColor.shade900,
        DefaultColors.secondaryColor.shade900
      ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Scaffold(
          body: Column(
        children: [
          SettingsAppBarWidget(refreshParent: refresh),
          const SizedBox(height: 10),
          getUserCard()
        ],
      )),
    ));
  }
}
