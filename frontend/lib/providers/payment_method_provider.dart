import 'package:flutter/material.dart';

import '../models/payment_method_model.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';

/// Métodos de pago del usuario, conectados a /api/payment-methods.
/// Sigue el mismo patrón que AddressProvider/FavoritesProvider: se
/// entera del login/logout vía [updateAuth] (ver main.dart). No
/// existen métodos de pago para "anónimo" (el backend exige sesión).
class PaymentMethodProvider extends ChangeNotifier {
  List<PaymentMethod> _methods = [];
  String? _token;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<PaymentMethod> get methods => _methods;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  void updateAuth(String? token) {
    final wasLoggedIn = _token != null;
    _token = token;

    if (token != null && !wasLoggedIn) {
      fetchPaymentMethods();
    } else if (token == null && wasLoggedIn) {
      _methods = [];
      notifyListeners();
    }
  }

  Future<void> fetchPaymentMethods() async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiClient.get('/payment-methods', token: _token);
      final raw = data['paymentMethods'] as List? ?? [];
      _methods = raw.map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>)).toList();
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crea un método de pago nuevo. Para type == 'CARD' el backend
  /// exige lastFourDigits (4 dígitos) + mes/año de expiración.
  Future<bool> createPaymentMethod({
    required String type,
    String provider = '',
    String name = '',
    String lastFourDigits = '',
    int? expirationMonth,
    int? expirationYear,
  }) async {
    if (_token == null) return false;
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await ApiClient.post('/payment-methods', token: _token, body: {
        'type': type,
        'provider': provider,
        'name': name,
        if (lastFourDigits.isNotEmpty) 'lastFourDigits': lastFourDigits,
        'expirationMonth': ?expirationMonth,
        'expirationYear': ?expirationYear,
      });
      _methods.add(PaymentMethod.fromJson(data['paymentMethod'] as Map<String, dynamic>));
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> setDefaultPaymentMethod(String id) async {
    if (_token == null) return false;

    try {
      await ApiClient.patch('/payment-methods/$id/default', token: _token);
      await fetchPaymentMethods();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  /// El backend hace "soft delete" (isActive = false), por lo que
  /// simplemente lo quitamos de la lista local tras confirmar.
  Future<bool> deletePaymentMethod(String id) async {
    if (_token == null) return false;

    final backup = List<PaymentMethod>.from(_methods);
    _methods.removeWhere((m) => m.id == id);
    notifyListeners();

    try {
      await ApiClient.delete('/payment-methods/$id', token: _token);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _methods = backup;
      notifyListeners();
      return false;
    }
  }
}
