import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // Inicializamos por defecto en ThemeMode.system para que tome la config del dispositivo
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  // Saber si el tema actual resulta en oscuro (útil para switches en la UI)
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Cambiar explícitamente a Claro u Oscuro desde los ajustes de la app
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  // Método auxiliar si solo usas un Switch booleano simple en tu UI
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  static const primaryBrown = Color(0xFFA2784F);

  // Tus temas se mantienen igual...
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