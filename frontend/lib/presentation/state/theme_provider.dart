import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  static const primaryBrown = Color(0xFFA2784F);

  ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFAF7F2),
        cardColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: primaryBrown,
          surface: Colors.white,
          onSurface: Colors.black87,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: primaryBrown,
          unselectedItemColor: Colors.grey,
        ),
      );

  ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E1410),
        cardColor: const Color(0xFF2C1E18),
        colorScheme: const ColorScheme.dark(
          primary: primaryBrown,
          surface: Color(0xFF2C1E18),
          onSurface: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF19100C),
          selectedItemColor: Color(0xFFC3A382),
          unselectedItemColor: Colors.white38,
        ),
      );
}