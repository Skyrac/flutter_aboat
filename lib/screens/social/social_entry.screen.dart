import 'package:flutter/material.dart';

import '../../themes/colors.dart';

class SocialEntryScreen extends StatefulWidget {
  const SocialEntryScreen({Key? key}) : super(key: key);

  @override
  State<SocialEntryScreen> createState() => _SocialEntryScreenState();
}

class _SocialEntryScreenState extends State<SocialEntryScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
            child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
      DefaultColors.primaryColor.shade900,
      DefaultColors.secondaryColor.shade900,
      DefaultColors.secondaryColor.shade900
    ], begin: Alignment.topLeft, end: Alignment.bottomRight)))));
  }
}
