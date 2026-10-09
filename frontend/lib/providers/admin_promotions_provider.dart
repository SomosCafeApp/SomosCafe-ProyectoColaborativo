import 'package:flutter/material.dart';

import '../models/promotion.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';

/// CRUD de promociones para el panel admin (todas las rutas están
/// protegidas con adminOnly en el backend):
///   GET/POST /promotions · PUT/DELETE /promotions/:id
///   PATCH /promotions/:id/promo-of-the-day
/// Habilitar/deshabilitar usa PUT con { isActive }.
class AdminPromotionsProvider extends ChangeNotifier {
  List<Promotion> _promotions = [];
  String? _token;
  bool _isAdmin = false;

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  /// Promoción sobre la que hay una acción en curso (toggle/borrar/promo del día).
  String? _busyPromotionId;

  List<Promotion> get promotions => _promotions;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get busyPromotionId => _busyPromotionId;

  void updateAuth(String? token, bool isAdmin) {
    _token = token;
    _isAdmin = isAdmin;

    if ((token == null || !isAdmin) && _promotions.isNotEmpty) {
      _promotions = [];
      _errorMessage = null;
      notifyListeners();
    }
  }

  bool get _canUse => _token != null && _isAdmin;

  Future<void> fetchPromotions() async {
    if (!_canUse) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await ApiClient.get('/promotions', token: _token);
      final raw = data['promotions'] as List? ?? [];
      _promotions = raw.map((e) => Promotion.fromJson(e as Map<String, dynamic>)).toList();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _body({
    required String code,
    required String name,
    required String description,
    required PromotionDiscountType discountType,
    required double discountValue,
    required double? maximumDiscount,
    required List<String> productIds,
    required DateTime startDate,
    required DateTime endDate,
  }) =>
      {
        'code': code.trim(),
        'name': name.trim(),
        'description': description.trim(),
        'discountType': discountType.apiValue,
        'discountValue': discountValue,
        // null = quitar el tope (el backend acepta null al editar).
        'maximumDiscount': maximumDiscount,
        'productIds': productIds,
        'startDate': startDate.toUtc().toIso8601String(),
        'endDate': endDate.toUtc().toIso8601String(),
      };

  /// Crea una promoción. Devuelve true si se creó; si no, [errorMessage]
  /// trae el motivo (ej. código duplicado).
  Future<bool> createPromotion({
    required String code,
    required String name,
    required String description,
    required PromotionDiscountType discountType,
    required double discountValue,
    required double? maximumDiscount,
    required List<String> productIds,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (!_canUse) return false;
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiClient.post('/promotions', token: _token, body: {
        ..._body(
          code: code,
          name: name,
          description: description,
          discountType: discountType,
          discountValue: discountValue,
          maximumDiscount: maximumDiscount,
          productIds: productIds,
          startDate: startDate,
          endDate: endDate,
        ),
        'isActive': true,
      });
      await fetchPromotions();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updatePromotion(
    String id, {
    required String code,
    required String name,
    required String description,
    required PromotionDiscountType discountType,
    required double discountValue,
    required double? maximumDiscount,
    required List<String> productIds,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (!_canUse) return false;
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiClient.put('/promotions/$id', token: _token, body: _body(
        code: code,
        name: name,
        description: description,
        discountType: discountType,
        discountValue: discountValue,
        maximumDiscount: maximumDiscount,
        productIds: productIds,
        startDate: startDate,
        endDate: endDate,
      ));
      await fetchPromotions();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Habilita o deshabilita. Deshabilitar también la quita como promo
  /// del día (lo hace el backend).
  Future<bool> setActive(String id, bool isActive) async {
    if (!_canUse) return false;
    return _runBusy(id, () async {
      await ApiClient.put('/promotions/$id', token: _token, body: {'isActive': isActive});
    });
  }

  /// Marca (o desmarca) la promo del día. Al marcar una, el backend
  /// desmarca la anterior.
  Future<bool> setPromoOfTheDay(String id, bool value) async {
    if (!_canUse) return false;
    return _runBusy(id, () async {
      await ApiClient.patch('/promotions/$id/promo-of-the-day', token: _token, body: {
        'isPromoOfTheDay': value,
      });
    });
  }

  Future<bool> deletePromotion(String id) async {
    if (!_canUse) return false;
    return _runBusy(id, () async {
      await ApiClient.delete('/promotions/$id', token: _token);
    });
  }

  Future<bool> _runBusy(String id, Future<void> Function() action) async {
    _busyPromotionId = id;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      await fetchPromotions();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _busyPromotionId = null;
      notifyListeners();
    }
  }
}
