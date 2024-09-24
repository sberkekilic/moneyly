import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

class Themes {
  static ThemeData lightTheme = FlexThemeData.light(
    scheme: FlexScheme.deepPurple,
    primary: const Color(0xff8315b5),
    background: Color(0xff114ba8),
    useMaterial3: true,
  );

  static ThemeData darkTheme = FlexThemeData.dark(
    scheme: FlexScheme.deepPurple,
    primary: const Color(0xff8315b5),
    useMaterial3: true,
  );
}