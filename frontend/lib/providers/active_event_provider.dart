import 'package:flutter/material.dart';

import '../models/app_event.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';

/// Evento activo para la ventana emergente de inicio
/// (GET /events/active, pública: no requiere sesión).
class ActiveEventProvider extends ChangeNotifier {
  AppEvent? _event;
  bool _popupShown = false;
  int _popupRequestCount = 0;

  AppEvent? get event => _event;

  /// El pop-up sale una sola vez por apertura de la app.
  bool get popupShown => _popupShown;

  void markPopupShown() => _popupShown = true;

  /// Contador de peticiones de "mostrar el pop-up ahora" (cuando el
  /// usuario toca la push de un evento nuevo). EventPopupGate lo
  /// escucha para mostrarlo y MainNavigationScreen para volver a Inicio.
  int get popupRequestCount => _popupRequestCount;

  void requestPopup() {
    _popupRequestCount++;
    notifyListeners();
  }

  /// Devuelve el evento activo (o null si no hay / falló la red: el
  /// arranque de la app nunca debe depender de esto).
  Future<AppEvent?> fetchActiveEvent() async {
    try {
      final data = await ApiClient.get('/events/active');
      final raw = data['event'];
      _event = raw is Map<String, dynamic> ? AppEvent.fromJson(raw) : null;
    } on ApiException {
      _event = null;
    }
    notifyListeners();
    return _event;
  }
}
