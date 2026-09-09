import 'package:flutter/material.dart';

class AppTheme {
  // --- Paleta de marca (única fuente de verdad) ---
  static const Color primaryBrown = Color(0xFFA2784F);
  static const Color darkBrown = Color(0xFF634832);
  static const Color backgroundLight = Color(0xFFFAF7F2);
  static const Color cardLight = Colors.white;

  static const Color backgroundDark = Color(0xFF1E1410);
  static const Color cardDark = Color(0xFF2D211B);
  static const Color primaryBrownDark = Color(0xFFC3A382);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBrown,
        brightness: Brightness.light,
        primary: primaryBrown,
        secondary: darkBrown,
        surface: cardLight,
        onSurface: Colors.black87,
      ),
      scaffoldBackgroundColor: backgroundLight,
      cardColor: cardLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBrown,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBrownDark,
        brightness: Brightness.dark,
        primary: primaryBrownDark,
        secondary: primaryBrown,
        surface: cardDark,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundDark,
      cardColor: cardDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBrown,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}