import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors_new.dart';

class NewDefaultTheme {
  static ThemeData get defaultTheme {
    return ThemeData(
        primaryColor: NewDefaultColors.primaryColor,
        cardTheme:
            CardTheme(color: NewDefaultColors.secondaryColor.shade800, shadowColor: NewDefaultColors.primaryColor.shade500),
        brightness: Brightness.dark,
        iconTheme: IconThemeData(color: NewDefaultColors.primaryColor.shade100),
        textTheme: GoogleFonts.interTextTheme(TextTheme(
          titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: NewDefaultColors.secondaryColor.shade50),
          titleMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: NewDefaultColors.secondaryColor.shade50),
          titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: NewDefaultColors.secondaryColor.shade50),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: NewDefaultColors.secondaryColor.shade50),
          labelMedium: TextStyle(fontSize: 10, color: NewDefaultColors.secondaryColor.shade50),
          labelSmall: TextStyle(fontSize: 8, color: NewDefaultColors.secondaryColor.shade50),
          headlineLarge: TextStyle(color: NewDefaultColors.secondaryColor.shade50),
          headlineMedium: TextStyle(color: NewDefaultColors.secondaryColor.shade50),
          headlineSmall: TextStyle(color: NewDefaultColors.secondaryColor.shade50),
          displayLarge: TextStyle(color: NewDefaultColors.secondaryColor.shade50),
          displayMedium: TextStyle(color: NewDefaultColors.secondaryColor.shade50),
          displaySmall: TextStyle(color: NewDefaultColors.secondaryColor.shade50),
          bodyLarge: TextStyle(color: NewDefaultColors.secondaryColor.shade50),
          bodyMedium: TextStyle(color: NewDefaultColors.secondaryColor.shade50),
          bodySmall: TextStyle(color: NewDefaultColors.secondaryColor.shade50),
        )),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: NewDefaultColors.primaryColor.shade100),
          hintStyle: TextStyle(color: NewDefaultColors.primaryColor.shade200),
        ),
        backgroundColor: Colors.transparent,
        popupMenuTheme: PopupMenuThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          color: NewDefaultColors.secondaryColor.shade800,
        ),
        bottomAppBarColor: NewDefaultColors.secondaryColor,
        dialogTheme: DialogTheme(backgroundColor: NewDefaultColors.secondaryColorAlphaBlend.shade600),
        dialogBackgroundColor: NewDefaultColors.secondaryColorAlphaBlend.shade600,
        scaffoldBackgroundColor: const Color(0x000f1729),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        fontFamily: 'Montserrat', //3
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: NewDefaultColors.primaryColor.shade900,
            unselectedItemColor: NewDefaultColors.primaryColor.shade200,
            selectedItemColor: NewDefaultColors.primaryColor.shade500,
            unselectedLabelStyle: TextStyle(color: NewDefaultColors.primaryColor.shade900)),
        buttonTheme: ButtonThemeData(
          // 4
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
          buttonColor: NewDefaultColors.primaryColor.shade300,
        ));
  }
}
