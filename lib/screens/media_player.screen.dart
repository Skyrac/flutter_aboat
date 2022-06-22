import 'package:flutter/material.dart';

import '../injection/injector.dart';
import '../services/state/state.service.dart';
import '../themes/colors.dart';

class MediaPlayerScreen extends StatefulWidget {
  const MediaPlayerScreen({Key? key}) : super(key: key);

  @override
  State<MediaPlayerScreen> createState() => _MediaPlayerScreenState();
}

class _MediaPlayerScreenState extends State<MediaPlayerScreen> {
  final stateService = getIt<StateService>();

  @override
  dispose() {
    stateService.closeDetailPlayer();
    super.dispose();
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
      ], begin: Alignment.topLeft, end: Alignment.bottomRight))),
    );
  }
}
