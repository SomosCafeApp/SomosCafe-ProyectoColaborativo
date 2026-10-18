import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_client.dart';
import '../services/api_exception.dart';
import '../services/google_auth_service.dart';
import '../services/push_service.dart';
import '../models/user_model.dart';

const _kTokenKey = 'auth_token';
const _kUserKey = 'auth_user';

/// Cada cuánto se renueva el JWT mientras la app está abierta (el token
/// dura 1 hora; renovamos bastante antes de que venza).
const _kRefreshEvery = Duration(minutes: 25);

class AuthProvider extends ChangeNotifier with WidgetsBindingObserver {
  AppUser? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  Timer? _refreshTimer;
  DateTime? _lastRefresh;
  bool _refreshing = false;
  bool _observing = false;

  /// Email pendiente de verificación (se llena justo después de un
  /// registro exitoso, o cuando un login falla por correo no verificado).
  String? _pendingVerificationEmail;

  bool get isLoggedIn => _user != null && _token != null;
  AppUser? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get pendingVerificationEmail => _pendingVerificationEmail;

  /// true si la cuenta logueada tiene rol ADMIN (backend: userModel.role).
  bool get isAdmin => isLoggedIn && _user?.role == 'ADMIN';

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

  /// Restaura la sesión guardada y RENUEVA el JWT contra el backend
  /// (POST /login/refresh), así el token vencido de la última vez ya
  /// no provoca errores. Llamar una vez al arrancar la app.
  ///
  /// - Si el backend lo renueva: sesión lista con token fresco.
  /// - Si responde 401 (pasaron más de 30 días, o la cuenta ya no
  ///   existe): se cierra la sesión.
  /// - Si no hay conexión: se conserva la sesión guardada (el token
  ///   se renovará solo cuando vuelva la conexión).
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kTokenKey);
    final userJson = prefs.getString(_kUserKey);

    if (token == null || userJson == null) return;

    _token = token;
    _user = AppUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);

    // Antes de avisar a los demás providers (que piden datos con el
    // token) lo renovamos, para que no arranquen con uno vencido.
    await refreshSession();

    if (_token != null) _startKeepAlive();
    notifyListeners();
  }

  /// Renueva el JWT y los datos del usuario (rol, puntos...).
  /// Devuelve true si quedó con token fresco.
  Future<bool> refreshSession() async {
    final current = _token;
    if (current == null || _refreshing) return false;

    _refreshing = true;
    try {
      final data = await ApiClient.post('/login/refresh', token: current);

      _token = data['token'] as String;
      _user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
      _lastRefresh = DateTime.now();
      await _persistSession(_token!, _user!);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      // 401 = el backend ya no acepta esta sesión: hay que volver a
      // iniciar sesión. Otros errores (sin red, timeout) no la cierran.
      if (e.statusCode == 401) {
        await _endSession();
      }
      return false;
    } finally {
      _refreshing = false;
    }
  }

  void _startKeepAlive() {
    ApiClient.onTokenExpired = () => refreshSession();

    if (!_observing) {
      WidgetsBinding.instance.addObserver(this);
      _observing = true;
    }

    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_kRefreshEvery, (_) => refreshSession());
  }

  void _stopKeepAlive() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Al volver a la app tras un rato en segundo plano, el token pudo
  /// vencer: se renueva si pasó más de la mitad de su vida.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || _token == null) return;

    final last = _lastRefresh;
    if (last == null || DateTime.now().difference(last) > const Duration(minutes: 20)) {
      refreshSession();
    }
  }

  @override
  void dispose() {
    _stopKeepAlive();
    if (_observing) WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Cierra la sesión local (sin tocar Google): la usa el refresco
  /// cuando el backend ya no acepta el token.
  Future<void> _endSession() async {
    _stopKeepAlive();
    _user = null;
    _token = null;
    notifyListeners();
    await _clearSession();
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
      _lastRefresh = DateTime.now();
      _startKeepAlive();

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

  /// Paso 1 de recuperación de contraseña: pide al backend que envíe
  /// el código de 6 dígitos al correo indicado.
  Future<bool> requestPasswordRecovery(String email) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await ApiClient.post('/recovery/request', body: {
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

  /// Paso 2 de recuperación de contraseña: valida el código y
  /// establece la nueva contraseña. No inicia sesión automáticamente;
  /// el usuario debe volver a loguearse con la nueva contraseña.
  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await ApiClient.post('/recovery/change-password', body: {
        'email': email.trim(),
        'code': code.trim(),
        'newPassword': newPassword,
      });
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    }
  }

  // ===================================
  // CUENTA (usuario logueado) → /api/account
  // ===================================

  /// Guarda los datos personales. [birthDate] ("AAAA-MM-DD") solo se
  /// acepta si todavía no tenía uno registrado. Devuelve true si se guardó.
  Future<bool> updateProfile({
    required String name,
    required String lastName,
    required String phone,
    String? birthDate,
  }) async {
    if (_token == null) return false;
    _setLoading(true);
    _errorMessage = null;
    try {
      final data = await ApiClient.patch('/account/profile', token: _token, body: {
        'name': name.trim(),
        'lastName': lastName.trim(),
        'phone': phone.trim(),
        if (birthDate != null) 'birthDate': birthDate,
      });
      _user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
      await _persistSession(_token!, _user!);
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _errorMessage = _translateAccountError(e.message);
      _setLoading(false);
      return false;
    }
  }

  /// Método 1: contraseña actual + nueva. La sesión sigue abierta.
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      _accountPasswordCall('/account/password', {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });

  /// Método 2, paso 1 ("¿Olvidaste tu contraseña?"): envía el código al
  /// correo de la cuenta logueada (no se pide el correo).
  Future<bool> requestOwnPasswordCode() => _accountPasswordCall('/account/password/code', const {});

  /// Método 2, paso 2: valida el código y guarda la nueva contraseña.
  Future<bool> changePasswordWithCode({
    required String code,
    required String newPassword,
  }) =>
      _accountPasswordCall('/account/password/reset', {
        'code': code.trim(),
        'newPassword': newPassword,
      });

  Future<bool> _accountPasswordCall(String path, Map<String, dynamic> body) async {
    if (_token == null) return false;
    _setLoading(true);
    _errorMessage = null;
    try {
      await ApiClient.post(path, token: _token, body: body);
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _errorMessage = _translateAccountError(e.message);
      _setLoading(false);
      return false;
    }
  }

  /// Elimina la cuenta (irreversible; el backend anonimiza los datos).
  /// [password] solo hace falta si la cuenta tiene contraseña. Si sale
  /// bien, cierra la sesión en este teléfono.
  Future<bool> deleteAccount({String? password}) async {
    if (_token == null) return false;
    _setLoading(true);
    _errorMessage = null;
    try {
      await ApiClient.post('/account/delete', token: _token, body: {
        if (password != null) 'password': password,
        'confirmation': 'ELIMINAR',
      });
      // La cuenta ya no existe: se limpia la sesión local sin intentar
      // dar de baja el dispositivo (el backend ya lo borró).
      _stopKeepAlive();
      _user = null;
      _token = null;
      _pendingVerificationEmail = null;
      _isLoading = false;
      notifyListeners();
      await _clearSession();
      GoogleAuthService.signOut().catchError((_) {});
      return true;
    } on ApiException catch (e) {
      _errorMessage = _translateAccountError(e.message);
      _setLoading(false);
      return false;
    }
  }

  String _translateAccountError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('current password is incorrect')) return 'La contraseña actual no es correcta';
    if (lower.contains('must be different')) return 'La nueva contraseña debe ser distinta a la actual';
    if (lower.contains('account has no password')) {
      return 'Tu cuenta no tiene contraseña (entraste con Google). Usa "¿Olvidaste tu contraseña?" para crear una';
    }
    if (lower.contains('invalid or expired recovery code')) return 'Código inválido o vencido';
    if (lower.contains('wait before requesting')) return 'Espera un minuto antes de pedir otro código';
    if (lower.contains('could not send recovery email')) return 'No pudimos enviar el correo. Intenta de nuevo';
    if (lower.contains('birth date can only be set once')) return 'El cumpleaños solo se puede registrar una vez';
    if (lower.contains('invalid birth date')) return 'Ingresa una fecha de nacimiento válida';
    if (lower.contains('invalid phone')) return 'Ingresa un teléfono válido';
    if (lower.contains('password is incorrect')) return 'La contraseña no es correcta';
    if (lower.contains('orders in progress')) {
      return 'Tienes pedidos en curso. Podrás eliminar tu cuenta cuando terminen';
    }
    if (lower.contains('admin accounts cannot')) return 'Las cuentas de administrador no se pueden eliminar';
    if (lower.contains('name is required')) return 'Ingresa tu nombre';
    if (lower.contains('password must contain') || lower.contains('password cannot exceed')) {
      return 'La contraseña debe tener mín. 6 caracteres, mayúscula, minúscula, número y carácter especial';
    }
    return message;
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
      _lastRefresh = DateTime.now();
      _startKeepAlive();

      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    // Desvincular este teléfono ANTES de borrar el token: el backend
    // necesita la sesión para aceptar la baja. Sin await para no
    // retrasar el cierre de sesión.
    final currentToken = _token;
    if (currentToken != null) {
      unawaited(PushService.instance.unregister(currentToken));
    }

    _stopKeepAlive();
    _user = null;
    _token = null;
    _pendingVerificationEmail = null;
    notifyListeners();
    await _clearSession();
    // Best-effort: no bloquea el logout si esto falla.
    GoogleAuthService.signOut().catchError((_) {});
  }
}
