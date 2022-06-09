import 'package:flutter/material.dart';
import 'package:talkaboat/screens/app.screen.dart';
import 'package:talkaboat/themes/default.theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: DefaultTheme.defaultTheme,
      debugShowCheckedModeBanner: false,
      home: const AppScreen(title: 'Talkaboat'),
    );
  }
}
