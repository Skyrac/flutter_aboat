import 'package:flutter/material.dart';

import 'colors.dart';

class DefaultTheme {
  static ThemeData get defaultTheme {
    return ThemeData(
        primaryColor: DefaultColors.primaryColor,
        iconTheme: IconThemeData(
          color: DefaultColors.primaryColor.shade100
        ),
        backgroundColor: DefaultColors.primaryColor.shade900,
        bottomAppBarColor: DefaultColors.secondaryColor,
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent, elevation: 0.0),
        fontFamily: 'Montserrat', //3
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: DefaultColors.primaryColor.shade900,
            unselectedItemColor: DefaultColors.primaryColor.shade200,
            selectedItemColor: DefaultColors.primaryColor.shade500,
            unselectedLabelStyle:
                TextStyle(color: DefaultColors.primaryColor.shade900)),
        buttonTheme: ButtonThemeData(
          // 4
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
          buttonColor: DefaultColors.primaryColor.shade300,
        ));
  }
}
