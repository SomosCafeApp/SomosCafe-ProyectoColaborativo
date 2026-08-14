import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userName;

  bool get isLoggedIn => _isLoggedIn;
  String? get userName => _userName;

  // Simulación de inicio de sesión
  void login(String username, String password) {
    if (username.isNotEmpty && password.length >= 6) {
      _isLoggedIn = true;
      _userName = username;
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