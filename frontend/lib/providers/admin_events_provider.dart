import 'package:flutter/material.dart';

import '../models/app_event.dart';
import '../models/picked_image.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';

/// CRUD de eventos para el panel admin (rutas protegidas con adminOnly):
///   GET    /events               → todos
///   POST   /events               → multipart (imagen → Cloudinary)
///   PUT    /events/:id           → multipart
///   PATCH  /events/:id/active    → activar/desactivar (solo uno activo)
///   DELETE /events/:id
class AdminEventsProvider extends ChangeNotifier {
  List<AppEvent> _events = [];
  String? _token;
  bool _isAdmin = false;

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _busyEventId;

  List<AppEvent> get events => _events;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get busyEventId => _busyEventId;

  bool get _canUse => _token != null && _isAdmin;

  void updateAuth(String? token, bool isAdmin) {
    _token = token;
    _isAdmin = isAdmin;

    if ((token == null || !isAdmin) && _events.isNotEmpty) {
      _events = [];
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> fetchEvents() async {
    if (!_canUse) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await ApiClient.get('/events', token: _token);
      final raw = data['events'] as List? ?? [];
      _events = raw.map((e) => AppEvent.fromJson(e as Map<String, dynamic>)).toList();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, String> _fields({
    required String name,
    required String description,
    required String location,
    required DateTime startDate,
    required DateTime endDate,
    bool? isActive,
  }) =>
      {
        'name': name.trim(),
        'description': description.trim(),
        'location': location.trim(),
        'startDate': startDate.toUtc().toIso8601String(),
        'endDate': endDate.toUtc().toIso8601String(),
        if (isActive != null) 'isActive': isActive.toString(),
      };

  Future<bool> createEvent({
    required String name,
    required String description,
    required String location,
    required DateTime startDate,
    required DateTime endDate,
    required bool isActive,
    PickedImage? image,
  }) {
    return _submit(() => ApiClient.sendMultipart(
          'POST',
          '/events',
          token: _token,
          fields: _fields(
            name: name,
            description: description,
            location: location,
            startDate: startDate,
            endDate: endDate,
            isActive: isActive,
          ),
          imageBytes: image?.bytes,
          imageName: image?.name,
        ));
  }

  Future<bool> updateEvent(
    String id, {
    required String name,
    required String description,
    required String location,
    required DateTime startDate,
    required DateTime endDate,
    PickedImage? image,
  }) {
    return _submit(() => ApiClient.sendMultipart(
          'PUT',
          '/events/$id',
          token: _token,
          fields: _fields(
            name: name,
            description: description,
            location: location,
            startDate: startDate,
            endDate: endDate,
          ),
          imageBytes: image?.bytes,
          imageName: image?.name,
        ));
  }

  Future<bool> _submit(Future<Map<String, dynamic>> Function() request) async {
    if (!_canUse) return false;
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await request();
      await fetchEvents();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Activa o desactiva. Activar uno desactiva el que estuviera activo
  /// (lo hace el backend).
  Future<bool> setActive(String id, bool isActive) {
    return _runBusy(id, () async {
      await ApiClient.patch('/events/$id/active', token: _token, body: {'isActive': isActive});
    });
  }

  Future<bool> deleteEvent(String id) {
    return _runBusy(id, () async {
      await ApiClient.delete('/events/$id', token: _token);
    });
  }

  Future<bool> _runBusy(String id, Future<void> Function() action) async {
    if (!_canUse) return false;
    _busyEventId = id;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      await fetchEvents();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _busyEventId = null;
      notifyListeners();
    }
  }
}
