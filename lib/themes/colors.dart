import 'package:flutter/material.dart';

class DefaultColors {
  DefaultColors._();

  static const primaryColorBase = Color.fromRGBO(100, 164, 253, 1);

  static final primaryColor =
      MaterialColor(primaryColorBase.value, const <int, Color>{
    50: Color.fromRGBO(240, 246, 255, 1),
    100: Color.fromRGBO(225, 237, 255, 1),
    200: Color.fromRGBO(195, 219, 254, 1),
    300: Color.fromRGBO(164, 202, 254, 1),
    400: Color.fromRGBO(129, 181, 253, 1),
    500: primaryColorBase,
    600: Color.fromRGBO(28, 122, 252, 1),
    700: Color.fromRGBO(3, 90, 212, 1),
    800: Color.fromRGBO(2, 60, 141, 1),
    900: Color.fromRGBO(1, 30, 71, 1),
  });

  static const secondaryColorBase = Color.fromRGBO(24, 40, 61, 1);

  static final secondaryColor =
      MaterialColor(primaryColorBase.value, const <int, Color>{
    50: Color.fromRGBO(226, 233, 243, 1),
    100: Color.fromRGBO(193, 209, 231, 1),
    200: Color.fromRGBO(134, 166, 207, 1),
    300: Color.fromRGBO(72, 120, 183, 1),
    400: Color.fromRGBO(48, 79, 121, 1),
    500: secondaryColorBase,
    600: Color.fromRGBO(19, 31, 48, 1),
    700: Color.fromRGBO(14, 24, 37, 1),
    800: Color.fromRGBO(10, 17, 26, 1),
    900: Color.fromRGBO(4, 7, 11, 1),
  });
}
