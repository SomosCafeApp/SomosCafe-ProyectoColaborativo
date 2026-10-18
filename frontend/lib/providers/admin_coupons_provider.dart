import 'package:flutter/material.dart';

import '../models/coupon.dart';
import '../models/promotion.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';

/// CRUD de cupones de recompensas para el panel admin (todas las rutas
/// van con adminOnly en el backend):
///   GET /coupons/admin · POST /coupons · PUT/DELETE /coupons/:id
///   PATCH /coupons/:id/status  → habilitar / deshabilitar / reactivar
class AdminCouponsProvider extends ChangeNotifier {
  List<Coupon> _coupons = [];
  String? _token;
  bool _isAdmin = false;

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  /// Cupón con una acción en curso (toggle / borrar / reactivar).
  String? _busyCouponId;

  List<Coupon> get coupons => _coupons;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get busyCouponId => _busyCouponId;

  void updateAuth(String? token, bool isAdmin) {
    _token = token;
    _isAdmin = isAdmin;

    if ((token == null || !isAdmin) && _coupons.isNotEmpty) {
      _coupons = [];
      _errorMessage = null;
      notifyListeners();
    }
  }

  bool get _canUse => _token != null && _isAdmin;

  Future<void> fetchCoupons() async {
    if (!_canUse) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await ApiClient.get('/coupons/admin', token: _token);
      _coupons = (data['coupons'] as List? ?? []).map((e) => Coupon.fromJson(e as Map<String, dynamic>)).toList();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _body({
    required String kind,
    required String name,
    required String description,
    required PromotionDiscountType discountType,
    required double discountValue,
    required double? maximumDiscount,
    required double minimumPurchase,
    required int pointsCost,
    required int? redeemLimit,
    required int? validDays,
  }) =>
      {
        'kind': kind,
        'name': name.trim(),
        'description': description.trim(),
        'discountType': discountType.apiValue,
        'discountValue': discountValue,
        // null = sin tope / sin límite / sin vencimiento.
        'maximumDiscount': maximumDiscount,
        'minimumPurchase': minimumPurchase,
        'pointsCost': pointsCost,
        'redeemLimit': redeemLimit,
        'validDays': validDays,
      };

  /// Crea un cupón. El backend avisa a todos los clientes (push +
  /// notificación). Devuelve true si se creó.
  Future<bool> createCoupon({
    required String kind,
    required String name,
    required String description,
    required PromotionDiscountType discountType,
    required double discountValue,
    required double? maximumDiscount,
    required double minimumPurchase,
    required int pointsCost,
    required int? redeemLimit,
    required int? validDays,
  }) =>
      _submit(() => ApiClient.post('/coupons',
          token: _token,
          body: _body(
            kind: kind,
            name: name,
            description: description,
            discountType: discountType,
            discountValue: discountValue,
            maximumDiscount: maximumDiscount,
            minimumPurchase: minimumPurchase,
            pointsCost: pointsCost,
            redeemLimit: redeemLimit,
            validDays: validDays,
          )));

  Future<bool> updateCoupon(
    String id, {
    required String kind,
    required String name,
    required String description,
    required PromotionDiscountType discountType,
    required double discountValue,
    required double? maximumDiscount,
    required double minimumPurchase,
    required int pointsCost,
    required int? redeemLimit,
    required int? validDays,
  }) =>
      _submit(() => ApiClient.put('/coupons/$id',
          token: _token,
          body: _body(
            kind: kind,
            name: name,
            description: description,
            discountType: discountType,
            discountValue: discountValue,
            maximumDiscount: maximumDiscount,
            minimumPurchase: minimumPurchase,
            pointsCost: pointsCost,
            redeemLimit: redeemLimit,
            validDays: validDays,
          )));

  Future<bool> _submit(Future<Map<String, dynamic>> Function() request) async {
    if (!_canUse) return false;
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await request();
      await fetchCoupons();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Deshabilita, o habilita. Habilitar un cupón deshabilitado o
  /// agotado lo REACTIVA: empieza un ciclo nuevo y quienes ya lo
  /// canjearon pueden canjearlo otra vez (lo decide el backend).
  Future<bool> setActive(String id, bool isActive) {
    if (!_canUse) return Future.value(false);
    return _runBusy(id, () async {
      await ApiClient.patch('/coupons/$id/status', token: _token, body: {'isActive': isActive});
    });
  }

  Future<bool> deleteCoupon(String id) {
    if (!_canUse) return Future.value(false);
    return _runBusy(id, () async {
      await ApiClient.delete('/coupons/$id', token: _token);
    });
  }

  Future<bool> _runBusy(String id, Future<void> Function() action) async {
    _busyCouponId = id;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      await fetchCoupons();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _busyCouponId = null;
      notifyListeners();
    }
  }
}
