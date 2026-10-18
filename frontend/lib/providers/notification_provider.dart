import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';
import '../services/push_service.dart';

/// Notificaciones del usuario, conectadas a /api/notifications.
/// Sigue el mismo patrón que AddressProvider/FavoritesProvider: se
/// entera del login/logout vía [updateAuth] (ver main.dart). No existen
/// notificaciones para "anónimo" (el backend exige sesión).
class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  // ----- Push -----
  // Preferencia guardada en el backend para ESTE dispositivo.
  bool _pushEnabled = true;
  // null = aún no se intentó registrar el dispositivo.
  PushStatus? _pushStatus;
  bool _registeringDevice = false;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// true si las push están realmente activas en este dispositivo
  /// (registrado en el backend y con el switch encendido).
  bool get pushActive => _pushStatus == PushStatus.registered && _pushEnabled;

  void updateAuth(String? token) {
    final wasLoggedIn = _token != null;
    _token = token;

    final push = PushService.instance;
    push.authTokenGetter = () => _token;
    push.onForegroundMessage = fetchNotifications;
    push.onDeviceTokenChanged = _registerDevice;

    if (token != null && !wasLoggedIn) {
      fetchNotifications();
      _registerDevice();
    } else if (token != null && _pushStatus == PushStatus.failed) {
      // El registro falló antes (p. ej. token vencido): se reintenta
      // cuando la sesión se renueva.
      _registerDevice();
    } else if (token == null && wasLoggedIn) {
      _notifications = [];
      _pushStatus = null;
      _pushEnabled = true;
      notifyListeners();
    }
  }

  /// Deja este dispositivo listo para recibir push (permiso + token FCM
  /// + registro en el backend).
  Future<void> _registerDevice() async {
    if (_token == null || _registeringDevice) return;
    _registeringDevice = true;

    try {
      final result = await PushService.instance.register();

      // Si cerró sesión mientras tanto, se ignora.
      if (_token == null) return;

      _pushStatus = result.status;
      if (result.status == PushStatus.registered) {
        _pushEnabled = result.pushEnabled;
      }
      notifyListeners();
    } finally {
      _registeringDevice = false;
    }
  }

  /// Switch "Push" de la pantalla de notificaciones. Devuelve el estado
  /// resultante para que la UI explique por qué no se pudo activar.
  Future<PushStatus> setPushEnabled(bool enabled) async {
    final token = _token;
    if (token == null) return PushStatus.failed;

    // Para encender, el dispositivo tiene que estar registrado (esto
    // vuelve a pedir el permiso del sistema si aún se puede).
    if (enabled && _pushStatus != PushStatus.registered) {
      await _registerDevice();
      if (_pushStatus != PushStatus.registered) {
        return _pushStatus ?? PushStatus.failed;
      }
    }

    // Sin dispositivo registrado no hay nada que apagar en el backend.
    if (_pushStatus != PushStatus.registered) {
      _pushEnabled = enabled;
      notifyListeners();
      return _pushStatus ?? PushStatus.failed;
    }

    final previous = _pushEnabled;
    _pushEnabled = enabled;
    notifyListeners();

    try {
      await PushService.instance.setPushPreference(token, enabled);
      return PushStatus.registered;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _pushEnabled = previous;
      notifyListeners();
      return PushStatus.failed;
    }
  }

  /// Las más recientes primero; las que no traen fecha quedan al final.
  static int _newestFirst(AppNotification a, AppNotification b) {
    final dateA = a.createdAt;
    final dateB = b.createdAt;
    if (dateA == null && dateB == null) return 0;
    if (dateA == null) return 1;
    if (dateB == null) return -1;
    return dateB.compareTo(dateA);
  }

  Future<void> fetchNotifications() async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiClient.get('/notifications', token: _token);
      final raw = data['notifications'] as List? ?? [];
      _notifications = raw.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList()
        ..sort(_newestFirst);
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    if (_token == null) return;

    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1 || _notifications[index].isRead) return;

    // Actualización optimista.
    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();

    try {
      await ApiClient.patch('/notifications/$id/read', token: _token);
    } on ApiException {
      // No revertimos: perder el estado "leído" por un error de red
      // no es grave y se corrige solo en el próximo fetch.
    }
  }

  Future<void> markAllAsRead() async {
    if (_token == null) return;
    if (unreadCount == 0) return;

    final backup = List<AppNotification>.from(_notifications);
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();

    try {
      await ApiClient.patch('/notifications/read-all', token: _token);
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _notifications = backup;
      notifyListeners();
    }
  }

  Future<bool> deleteNotification(String id) async {
    if (_token == null) return false;

    final backup = List<AppNotification>.from(_notifications);
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();

    try {
      await ApiClient.delete('/notifications/$id', token: _token);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _notifications = backup;
      notifyListeners();
      return false;
    }
  }
}
