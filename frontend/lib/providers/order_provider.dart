import 'package:flutter/material.dart';

import '../models/order.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';
import 'cart_provider.dart';

/// Pedidos del usuario, conectados a /api/orders.
/// Sigue el mismo patrón que CartProvider/AddressProvider: se entera
/// del login/logout vía [updateAuth] (ver main.dart).
class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  String? _token;

  bool _isLoading = false;
  bool _isCreating = false;
  String? _errorMessage;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  String? get errorMessage => _errorMessage;

  void updateAuth(String? token) {
    final wasLoggedIn = _token != null;
    _token = token;

    if (token != null && !wasLoggedIn) {
      fetchOrders();
    } else if (token == null && wasLoggedIn) {
      _orders = [];
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchOrders() async {
    if (_token == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await ApiClient.get('/orders/my-orders', token: _token);
      final raw = data['orders'] as List? ?? [];
      _orders = raw.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crea el pedido a partir del carrito actual. El backend recalcula
  /// precios y subtotales desde la base de datos (solo le mandamos
  /// productId + quantity), así que lo que el cliente envíe de más no
  /// se usa para el cobro real.
  ///
  /// [notes] se usa aquí también para guardar el método de pago
  /// elegido en texto libre, ya que todavía no hay métodos de pago
  /// reales conectados (PaymentMethod) del lado del backend.
  Future<Order?> createOrder({
    required String addressId,
    required List<CartLine> lines,
    String notes = '',
  }) async {
    if (_token == null) {
      _errorMessage = 'Debes iniciar sesión para realizar un pedido';
      notifyListeners();
      return null;
    }

    if (lines.isEmpty) {
      _errorMessage = 'Tu carrito está vacío';
      notifyListeners();
      return null;
    }

    _isCreating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await ApiClient.post('/orders', token: _token, body: {
        'addressId': addressId,
        'items': lines
            .map((l) => {
                  'productId': l.product.id,
                  'quantity': l.quantity,
                })
            .toList(),
        'notes': notes,
      });

      final order = Order.fromJson(data['order'] as Map<String, dynamic>);
      _orders.insert(0, order);

      _isCreating = false;
      notifyListeners();
      return order;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isCreating = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    if (_token == null) return false;

    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return false;

    try {
      await ApiClient.patch('/orders/$orderId/cancel', token: _token);
      // Recargamos ese pedido para reflejar el estado real (CANCELLED
      // + cancelledAt) en vez de intentar reconstruirlo a mano.
      await fetchOrders();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }
}
