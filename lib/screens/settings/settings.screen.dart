import 'package:Talkaboat/screens/settings/earnings.screen.dart';
import 'package:Talkaboat/services/dynamiclinks/dynamic-links.service.dart';
import 'package:Talkaboat/themes/colors_new.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:social_login_buttons/social_login_buttons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../injection/injector.dart';
import '../../services/downloading/file-downloader.service.dart';
import '../../services/user/user.service.dart';
import '../../themes/colors.dart';
import '../../utils/modal.widget.dart';
import '../../widgets/settings-app-bar.widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key, this.refresh}) : super(key: key);
  final Function? refresh;
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserService userService = getIt<UserService>();

  refresh() {
    setState(() {});
    if (widget.refresh != null) {
      widget.refresh!();
    }
  }

  Widget getUserCard() {
    return userService.userInfo == null || userService.userInfo!.userName == null
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
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
        child: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        DefaultColors.primaryColor.shade900,
        DefaultColors.secondaryColor.shade900,
        DefaultColors.secondaryColor.shade900
      ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Scaffold(
          body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsAppBarWidget(refreshParent: refresh),
            const SizedBox(height: 10),
            getUserCard(),
            const SizedBox(height: 10),
            createMenuPoint(Text(AppLocalizations.of(context)!.earnings), () {
              Navigator.push(
                  context,
                  PageTransition(
                      alignment: Alignment.centerRight,
                      curve: Curves.bounceOut,
                      type: PageTransitionType.rightToLeftWithFade,
                      duration: const Duration(milliseconds: 300),
                      reverseDuration: const Duration(milliseconds: 200),
                      child: const EarningsScreen()));
            }, true),

            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.5, vertical: 0),
              child: Text(AppLocalizations.of(context)!.refDesc, style: Theme.of(context).textTheme.titleLarge)),
              createMenuPoint(
                Text(AppLocalizations.of(context)!.shareRef,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith()), () async {
              final refLink = await DynamicLinkUtils.createInvite();
              Share.share("$refLink");
            }, false, showTrailing: false),
            SizedBox(height: height * 0.25),
            Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  IconButton(onPressed: ( () async => {
                    await launchUrl(Uri.parse("https://t.me/talkaboat"))
                  }), iconSize: 32, color: Colors.lightBlue, icon: const Icon(FontAwesomeIcons.telegram)),
                  Text("Telegram")
                ],),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                  IconButton(onPressed: ( () async => {
                    await launchUrl(Uri.parse("https://twitter.com/talkaboat"))
                  }), iconSize: 32, color: Colors.lightBlueAccent, icon: const Icon(FontAwesomeIcons.twitter)),
                  Text("Twitter")
                ],),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  IconButton(onPressed: ( () async => {
                    await launchUrl(Uri.parse("https://aboat-entertainment.com"))
                  }), iconSize: 32, color: Colors.grey, icon: const Icon(Icons.blur_circular)),
                  Text("Website")
                ],),
              ),
            ],),
            createMenuPoint(
                Text(AppLocalizations.of(context)!.clearCache,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey)), () {
              createClearCacheAlert(context);
            }, false, showTrailing: false),
            createMenuPoint(
                Text(
                  AppLocalizations.of(context)!.deleteAccount,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.red),
                ), () {
              showAlert(
                  context,
                  deletionTextController,
                  AppLocalizations.of(context)!.confirmDeletion,
                  AppLocalizations.of(context)!.enterUsernameToConfirmDeletion,
                  AppLocalizations.of(context)!.username,
                  completeDeletion);
            }, true, showTrailing: false)
          ],
        ),
      )),
    ));
  }

  final deletionTextController = TextEditingController();
  completeDeletion() async {
    setState(() {
      Navigator.of(context, rootNavigator: true).pop();
    });
    if (deletionTextController.text == userService.userInfo?.userName) {
      await userService.deleteAccount();
    }
    setState(() {});
  }

  createClearCacheAlert(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(AppLocalizations.of(context)!.cancel),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text(AppLocalizations.of(context)!.clearCache,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.red)),
      onPressed: () async {
        await FileDownloadService.clearCache();
        setState(() {
          Navigator.of(context, rootNavigator: true).pop();
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context)!.clearCacheConfirmation),
      content: Text(AppLocalizations.of(context)!.clearing),
      actions: [
        continueButton,
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  createMenuPoint(Widget title, click, onlyWhenSignedIn, {showTrailing = true}) {
    return !onlyWhenSignedIn || userService.isConnected
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0),
            child: TextButton(
                onPressed: click,
                child: Row(
                  children: [
                    Expanded(child: title),
                    showTrailing ? const Icon(Icons.navigate_next_outlined) : const SizedBox()
                  ],
                ),
            style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(NewDefaultColors.secondaryColorAlphaBlend.shade700))),
          )
        : const SizedBox();
  }
}
