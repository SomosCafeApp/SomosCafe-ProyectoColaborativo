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

  /// [silent] = true no muestra el indicador de carga (se usa en el
  /// refresco automático de OrdersPage para ver los cambios de estado
  /// que hace el administrador).
  Future<void> fetchOrders({bool silent = false}) async {
    if (_token == null) return;

    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final data = await ApiClient.get('/orders/my-orders', token: _token);
      final raw = data['orders'] as List? ?? [];
      _orders = raw.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
      _errorMessage = null;
    } on ApiException catch (e) {
      // En un refresco silencioso un fallo de red no debe tapar la lista.
      if (!silent) _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crea el pedido. Solo mandamos QUÉ se pidió (producto, cantidad y
  /// personalización) y los datos de entrega/pago elegidos: el backend
  /// calcula precios, personalizaciones, envío, descuento y total.
  ///
  /// NO vacía el carrito: quien llama lo hace solo si esto devuelve
  /// una orden (ver OrderConfirmationPage).
  Future<Order?> createOrder({
    required List<CartLine> lines,
    required DeliveryType deliveryType,
    required String recipientName,
    required String recipientPhone,
    required String paymentMethodId,
    String? addressId,
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
        'deliveryType': deliveryType.apiValue,
        'recipientName': recipientName.trim(),
        'recipientPhone': recipientPhone.trim(),
        'paymentMethodId': paymentMethodId,
        if (deliveryType == DeliveryType.delivery && addressId != null) 'addressId': addressId,
        'notes': notes.trim(),
        'items': lines
            .map((l) => {
                  'productId': l.product.id,
                  'quantity': l.quantity,
                  'customization': l.customization.toJson(),
                })
            .toList(),
      });

      final order = Order.fromJson(data['order'] as Map<String, dynamic>);
      _orders.insert(0, order);

      _isCreating = false;
      notifyListeners();
      return order;
    } on ApiException catch (e) {
      _errorMessage = _translateCreateError(e.message);
      _isCreating = false;
      notifyListeners();
      return null;
    }
  }

  String _translateCreateError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('is not available')) {
      return 'Algún producto de tu carrito ya no está disponible. Quítalo para continuar.';
    }
    if (lower.contains('products were not found')) {
      return 'Algún producto de tu carrito ya no existe. Quítalo para continuar.';
    }
    return message;
  }

  /// Cancela un pedido. El backend comprueba que sea del usuario, que
  /// el estado lo permita y que no hayan pasado los 10 minutos.
  Future<bool> cancelOrder(String orderId) async {
    if (_token == null) return false;

    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return false;

    try {
      await ApiClient.patch('/orders/$orderId/cancel', token: _token);
      // Recargamos para reflejar el estado real (CANCELLED + cancelledAt).
      await fetchOrders(silent: true);
      return true;
    } on ApiException catch (e) {
      _errorMessage = _translateCancelError(e.message);
      // El estado local pudo quedar desfasado (ej. el admin ya lo
      // confirmó/preparó): lo actualizamos.
      await fetchOrders(silent: true);
      return false;
    }
  }

  String _translateCancelError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('window has expired')) {
      return 'Ya pasaron los 10 minutos para cancelar este pedido';
    }
    if (lower.contains('no longer be cancelled')) {
      return 'Este pedido ya no se puede cancelar';
    }
    return message;
  }
}
