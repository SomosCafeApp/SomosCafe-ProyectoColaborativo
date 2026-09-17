import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_client.dart';
import '../services/api_exception.dart';
import '../models/user_model.dart';

const _kTokenKey = 'auth_token';
const _kUserKey = 'auth_user';

class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  /// Email pendiente de verificación (se llena justo después de un
  /// registro exitoso, o cuando un login falla por correo no verificado).
  String? _pendingVerificationEmail;

  bool get isLoggedIn => _user != null && _token != null;
  AppUser? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get pendingVerificationEmail => _pendingVerificationEmail;

  // Se mantiene por compatibilidad con widgets que ya leían `userName`.
  String? get userName => _user?.name;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Intenta restaurar la sesión guardada. Llamar una vez al arrancar la app.
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kTokenKey);
    final userJson = prefs.getString(_kUserKey);

    if (token == null || userJson == null) return;

    _token = token;
    _user = AppUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    notifyListeners();
  }

  Future<void> _persistSession(String token, AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTokenKey, token);
    await prefs.setString(_kUserKey, jsonEncode(user.toJson()));
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
    await prefs.remove(_kUserKey);
  }

  /// Login tradicional (email + contraseña).
  /// Devuelve true si fue exitoso.
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final data = await ApiClient.post('/login', body: {
        'email': email.trim(),
        'password': password,
      });

      _token = data['token'] as String;
      _user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
      await _persistSession(_token!, _user!);

      _pendingVerificationEmail = null;
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      // El backend devuelve 403 con este mensaje cuando el correo
      // aún no ha sido verificado. Guardamos el email para poder
      // llevar al usuario directo a la pantalla de verificación.
      if (e.message.toLowerCase().contains('verify your email')) {
        _pendingVerificationEmail = email.trim().toLowerCase();
      }
      _setLoading(false);
      return false;
    }
  }

  /// Registro tradicional. Si tiene éxito, dispara automáticamente el
  /// envío del código de verificación (el backend no deja iniciar
  /// sesión hasta que el correo esté verificado).
  Future<bool> register({
    required String name,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await ApiClient.post('/users/register', body: {
        'name': name.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
        'password': password,
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      });

      _pendingVerificationEmail = email.trim().toLowerCase();

      // Disparamos el envío del código; si falla, igual dejamos que
      // el usuario lo pida de nuevo desde la pantalla de verificación.
      try {
        await ApiClient.post('/users/request-email-verification', body: {
          'email': _pendingVerificationEmail,
        });
      } catch (_) {}

      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    }
  }

  Future<bool> requestEmailVerification(String email) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await ApiClient.post('/users/request-email-verification', body: {
        'email': email.trim(),
      });
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyEmail(String email, String code) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await ApiClient.post('/users/verify-email', body: {
        'email': email.trim(),
        'code': code.trim(),
      });
      _pendingVerificationEmail = null;
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resendVerificationCode(String email) async {
    return requestEmailVerification(email);
  }

  /// Login/registro con Google. [idToken] debe venir del flujo de
  /// google_sign_in en el frontend.
  Future<bool> loginWithGoogle(String idToken) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final data = await ApiClient.post('/users/login-google', body: {
        'idToken': idToken,
      });

      _token = data['token'] as String;
      _user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
      await _persistSession(_token!, _user!);

      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    _pendingVerificationEmail = null;
    notifyListeners();
    await _clearSession();
  }
}
