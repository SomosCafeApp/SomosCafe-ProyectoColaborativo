import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de colores inspirada en café (Corregida)
  static const Color primaryCoffee = Color(0xFF8D6E63); // Café suave
  static const Color darkCoffee = Color(0xFF4E342E);    // Café oscuro
  static const Color backgroundLight = Color(0xFFD7CCC8); // Fondo claro / crema

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryCoffee,
        primary: primaryCoffee,
        secondary: darkCoffee,
      ),
      scaffoldBackgroundColor: const Color(0xFFFAF8F6),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryCoffee,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}