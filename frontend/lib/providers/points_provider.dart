import 'package:flutter/material.dart';

import '../models/points_model.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';

/// Puntos de recompensas del usuario, conectados a /api/points.
/// Sigue el mismo patrón que ReviewsProvider: necesita tanto el
/// [token] como el [userId] (las rutas del backend van por
/// /points/user/:userId). No hay puntos para "anónimo".
class PointsProvider extends ChangeNotifier {
  String? _token;
  String? _userId;

  int _balance = 0;
  List<PointHistoryEntry> _history = [];
  bool _isLoading = false;
  bool _isRedeeming = false;
  String? _errorMessage;

  int get balance => _balance;
  List<PointHistoryEntry> get history => _history;
  bool get isLoading => _isLoading;
  bool get isRedeeming => _isRedeeming;
  String? get errorMessage => _errorMessage;

  void updateAuth(String? token, String? userId) {
    final wasLoggedIn = _token != null;
    _token = token;
    _userId = userId;

    if (token != null && !wasLoggedIn) {
      fetchBalance();
    } else if (token == null && wasLoggedIn) {
      _balance = 0;
      _history = [];
      notifyListeners();
    }
  }

  Future<void> fetchBalance() async {
    if (_token == null || _userId == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiClient.get('/points/user/$_userId', token: _token);
      _balance = (data['points'] as num?)?.toInt() ?? 0;
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHistory() async {
    if (_token == null || _userId == null) return;

    try {
      final data = await ApiClient.get('/points/user/$_userId/history', token: _token);
      final raw = data['points'] as List? ?? [];
      _history = raw.map((e) => PointHistoryEntry.fromJson(e as Map<String, dynamic>)).toList();
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  /// Canjea [amount] puntos por una recompensa. El backend valida que
  /// el usuario tenga saldo suficiente; el userId se toma del token,
  /// nunca de lo que mande el cliente.
  Future<bool> redeemPoints({required int amount, required String description}) async {
    if (_token == null) return false;
    _isRedeeming = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await ApiClient.post('/points/redeem', token: _token, body: {
        'amount': amount,
        'description': description,
      });
      _balance = (data['currentBalance'] as num?)?.toInt() ?? _balance;
      _isRedeeming = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isRedeeming = false;
      notifyListeners();
      return false;
    }
  }
}
