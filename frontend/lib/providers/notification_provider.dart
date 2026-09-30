import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';

/// Notificaciones del usuario, conectadas a /api/notifications.
/// Sigue el mismo patrón que AddressProvider/FavoritesProvider: se
/// entera del login/logout vía [updateAuth] (ver main.dart). No existen
/// notificaciones para "anónimo" (el backend exige sesión).
class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void updateAuth(String? token) {
    final wasLoggedIn = _token != null;
    _token = token;

    if (token != null && !wasLoggedIn) {
      fetchNotifications();
    } else if (token == null && wasLoggedIn) {
      _notifications = [];
      notifyListeners();
    }
  }

  Future<void> fetchNotifications() async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiClient.get('/notifications', token: _token);
      final raw = data['notifications'] as List? ?? [];
      _notifications = raw.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
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
