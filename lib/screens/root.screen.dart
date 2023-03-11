import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/screens/app.screen.dart';
import 'package:Talkaboat/screens/login.screen.dart';
import 'package:Talkaboat/screens/onboarding/onboarding.screen.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../services/ads/ad-manager.service.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  final userService = getIt<UserService>();
  String _authStatus = 'Unknown';

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async => await initPlugin());
    super.initState();
  }
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlugin() async {
    final TrackingStatus status =
    await AppTrackingTransparency.trackingAuthorizationStatus;

    setState(() => _authStatus = '$status');
    debugPrint("$status: ${status.name}");
    // If the system can show an authorization request dialog
    if (status == TrackingStatus.notDetermined) {
      // Show a custom explainer dialog before the system dialog
      await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Dear User'),
            content: Text(AppLocalizations.of(context)!.appTrackingCustomText),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continue'),
              ),
            ],
          ));
      // Wait for dialog popping animation
      await Future.delayed(const Duration(milliseconds: 200));
      // Request system's tracking authorization dialog
      final TrackingStatus status =
      await AppTrackingTransparency.requestTrackingAuthorization();
      setState(() => _authStatus = '$status');
    }

    final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
    AdManager.setAdvertismentIdentifier(uuid);
    print("UUID: $uuid");
  }

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
