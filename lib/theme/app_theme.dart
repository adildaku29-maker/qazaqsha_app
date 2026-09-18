import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF0F766E);
  static const Color background = Color(0xFFF7F8F6);
  static const Color text = Color(0xFF111827);
  static const Color secondaryText = Color(0xFF6B7280);

  static ThemeData theme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    fontFamily: 'Arial',

    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      centerTitle: false,
    ),
  );
}
