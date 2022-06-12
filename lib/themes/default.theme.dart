import 'package:flutter/material.dart';

import 'colors.dart';

class DefaultTheme {
  static ThemeData get defaultTheme {
    return ThemeData(
        primaryColor: DefaultColors.primaryColor,
        cardColor: DefaultColors.secondaryColor.shade800,
        iconTheme: IconThemeData(color: DefaultColors.primaryColor.shade100),
        textTheme: TextTheme(
          titleLarge: TextStyle(color: DefaultColors.secondaryColor),
          titleMedium: TextStyle(color: DefaultColors.secondaryColor),
          titleSmall: TextStyle(color: DefaultColors.secondaryColor),
          labelLarge: TextStyle(color: DefaultColors.secondaryColor),
          labelMedium: TextStyle(color: DefaultColors.secondaryColor),
          labelSmall: TextStyle(color: DefaultColors.secondaryColor),
          headlineLarge: TextStyle(color: DefaultColors.secondaryColor),
          headlineMedium: TextStyle(color: DefaultColors.secondaryColor),
          headlineSmall: TextStyle(color: DefaultColors.secondaryColor),
          displayLarge: TextStyle(color: DefaultColors.secondaryColor),
          displayMedium: TextStyle(color: DefaultColors.secondaryColor),
          displaySmall: TextStyle(color: DefaultColors.secondaryColor),
          bodyLarge: TextStyle(color: DefaultColors.secondaryColor),
          bodyMedium: TextStyle(color: DefaultColors.secondaryColor),
          bodySmall: TextStyle(color: DefaultColors.secondaryColor),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: DefaultColors.primaryColor.shade100),
          hintStyle: TextStyle(color: DefaultColors.primaryColor.shade200),
        ),
        backgroundColor: Colors.transparent,
        bottomAppBarColor: DefaultColors.secondaryColor,
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
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
