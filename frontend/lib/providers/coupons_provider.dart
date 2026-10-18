import 'package:flutter/material.dart';

import '../models/coupon.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';

/// Resultado de un canje: el cupón recibido y el saldo de puntos
/// que quedó (el servidor es la fuente de verdad).
class RedeemResult {
  final UserCoupon coupon;
  final int balance;

  const RedeemResult({required this.coupon, required this.balance});
}

/// Cupones de recompensas del cliente, conectados a /api/coupons:
///   GET /coupons        catálogo de cupones habilitados
///   GET /coupons/mine   cupones que ya canjeó
///   POST /coupons/:id/redeem
/// Se entera del login/logout vía [updateAuth] (ver main.dart).
class CouponsProvider extends ChangeNotifier {
  String? _token;

  List<Coupon> _catalog = [];
  List<UserCoupon> _mine = [];
  bool _isLoading = false;
  String? _redeemingId;
  String? _errorMessage;

  List<Coupon> get catalog => _catalog;
  List<UserCoupon> get mine => _mine;
  bool get isLoading => _isLoading;
  String? get redeemingId => _redeemingId;
  String? get errorMessage => _errorMessage;

  /// Cupones que se pueden usar ahora en un pedido.
  List<UserCoupon> get available => _mine.where((c) => c.isUsable).toList();

  void updateAuth(String? token) {
    final wasLoggedIn = _token != null;
    _token = token;

    if (token != null && !wasLoggedIn) {
      fetchAll();
    } else if (token == null && wasLoggedIn) {
      _catalog = [];
      _mine = [];
      notifyListeners();
    }
  }

  Future<void> fetchAll() async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        ApiClient.get('/coupons', token: _token),
        ApiClient.get('/coupons/mine', token: _token),
      ]);
      _catalog = (results[0]['coupons'] as List? ?? [])
          .map((e) => Coupon.fromJson(e as Map<String, dynamic>))
          .toList();
      _mine = _sortMine((results[1]['coupons'] as List? ?? [])
          .map((e) => UserCoupon.fromJson(e as Map<String, dynamic>))
          .toList());
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Solo recarga "Mis cupones" (ej. después de usar uno en un pedido).
  Future<void> fetchMine() async {
    if (_token == null) return;
    try {
      final data = await ApiClient.get('/coupons/mine', token: _token);
      _mine = _sortMine((data['coupons'] as List? ?? [])
          .map((e) => UserCoupon.fromJson(e as Map<String, dynamic>))
          .toList());
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    }
  }

  // Disponibles primero; luego usados y vencidos.
  List<UserCoupon> _sortMine(List<UserCoupon> list) {
    int rank(UserCoupon c) => c.isUsable ? 0 : 1;
    final sorted = List<UserCoupon>.from(list);
    sorted.sort((a, b) => rank(a).compareTo(rank(b)));
    return sorted;
  }

  /// Canjea un cupón con puntos. Devuelve el resultado o null si falló
  /// (en ese caso [errorMessage] trae el motivo en español).
  Future<RedeemResult?> redeem(Coupon coupon) async {
    if (_token == null) return null;
    _redeemingId = coupon.id;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await ApiClient.post('/coupons/${coupon.id}/redeem', token: _token);
      final result = RedeemResult(
        coupon: UserCoupon.fromJson(data['coupon'] as Map<String, dynamic>),
        balance: (data['currentBalance'] as num?)?.toInt() ?? 0,
      );
      await fetchAll();
      return result;
    } on ApiException catch (e) {
      _errorMessage = _translate(e.message);
      // El catálogo pudo cambiar (agotado, deshabilitado...): lo actualizamos.
      await fetchAll();
      return null;
    } finally {
      _redeemingId = null;
      notifyListeners();
    }
  }

  String _translate(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('insufficient points')) return 'No tienes suficientes puntos para este cupón';
    if (lower.contains('already redeemed')) return 'Ya canjeaste este cupón';
    if (lower.contains('sold out')) return 'Este cupón se agotó';
    if (lower.contains('not available')) return 'Este cupón ya no está disponible';
    return message;
  }
}
