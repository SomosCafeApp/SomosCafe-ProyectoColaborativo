import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = true; // Controla la verificación inicial de almacenamiento
  String? _userName;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get userName => _userName;

  AuthProvider() {
    _checkInitialAuth();
  }

  // Verifica credenciales/token guardados en almacenamiento persistente
  Future<void> _checkInitialAuth() async {
    try {
      // AQUÍ PUEDES CONSULTAR TU ALMACENAMIENTO PERSISTENTE (Ej: SharedPreferences):
      // final savedToken = await prefs.getString('token');
      // if (savedToken != null) { _isLoggedIn = true; }
      
      await Future.delayed(const Duration(milliseconds: 300)); // Simulación de lectura rápida
    } catch (_) {
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Simulación de inicio de sesión
  void login(String username, String password) {
    if (username.isNotEmpty && password.length >= 6) {
      _isLoggedIn = true;
      _userName = username;
      notifyListeners();
    }
  }

  // Simulación de registro
  void register(String name, String email, String password) {
    if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
      _isLoggedIn = true;
      _userName = name;
      notifyListeners();
    }
  }

  // Cierre de sesión
  void logout() {
    _isLoggedIn = false;
    _userName = null;
    notifyListeners();
  }
}