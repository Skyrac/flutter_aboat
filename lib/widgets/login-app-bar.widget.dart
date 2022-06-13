import 'package:flutter/material.dart';

class LoginAppBarWidget extends StatelessWidget {
  const LoginAppBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Login'),
    );
  }
}
