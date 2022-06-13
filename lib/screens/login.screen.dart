import 'package:flutter/material.dart';
import 'package:talkaboat/widgets/login-app-bar.widget.dart';

import '../themes/colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
        children: const [LoginAppBarWidget()],
      )),
    ));
  }
}
