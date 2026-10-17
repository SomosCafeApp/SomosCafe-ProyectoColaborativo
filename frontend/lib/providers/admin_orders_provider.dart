import 'package:flutter/material.dart';

import '../models/order.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';

/// Pedidos de TODOS los usuarios para el panel admin.
/// Reutiliza GET /orders, PATCH /orders/:id/status, DELETE /orders/:id
/// y PATCH /orders/:id/payment/(validate|invalidate) (todas protegidas
/// con adminOnly en el backend: aunque alguien llegara a esta pantalla
/// sin ser admin, el servidor lo rechaza).
class AdminOrdersProvider extends ChangeNotifier {
  List<Order> _orders = [];
  String? _token;
  bool _isAdmin = false;

  bool _isLoading = false;
  String? _errorMessage;

  /// Pedido sobre el que hay una acción en curso (cambio de estado o borrado).
  String? _busyOrderId;

  OrderStatus? _statusFilter;

  /// Filtro rápido: solo pedidos con comprobante esperando validación.
  bool _validationFilter = false;
  String _searchQuery = '';

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get busyOrderId => _busyOrderId;
  OrderStatus? get statusFilter => _statusFilter;
  bool get validationFilter => _validationFilter;
  String get searchQuery => _searchQuery;

  /// Pedidos tras aplicar filtro de estado y búsqueda (por número de
  /// pedido, cliente, correo, receptor o teléfono).
  List<Order> get filteredOrders {
    final query = _searchQuery.trim().toLowerCase();

    return _orders.where((o) {
      if (_statusFilter != null && o.status != _statusFilter) return false;
      if (_validationFilter && !o.awaitsValidation) return false;
      if (query.isEmpty) return true;

      final haystack = [
        o.shortId,
        o.id,
        o.customerName,
        o.customerEmail,
        o.customerPhone,
        o.recipientName,
        o.recipientPhone,
      ].join(' ').toLowerCase();

      return haystack.contains(query);
    }).toList();
  }

  int countFor(OrderStatus? status) =>
      status == null ? _orders.length : _orders.where((o) => o.status == status).length;

  /// Pedidos con comprobante subido que el admin aún debe validar.
  int get pendingValidationCount => _orders.where((o) => o.awaitsValidation).length;

  void updateAuth(String? token, bool isAdmin) {
    final wasAdmin = _token != null && _isAdmin;
    _token = token;
    _isAdmin = isAdmin;

    if (token == null || !isAdmin) {
      if (wasAdmin || _orders.isNotEmpty) {
        _orders = [];
        _statusFilter = null;
        _validationFilter = false;
        _searchQuery = '';
        _errorMessage = null;
        notifyListeners();
      }
    }
  }

  void setStatusFilter(OrderStatus? status) {
    _statusFilter = status;
    _validationFilter = false;
    notifyListeners();
  }

  void setValidationFilter() {
    _validationFilter = true;
    _statusFilter = null;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchOrders({bool silent = false}) async {
    if (_token == null || !_isAdmin) return;

    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final data = await ApiClient.get('/orders', token: _token);
      final raw = data['orders'] as List? ?? [];
      _orders = raw.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
      _errorMessage = null;
    } on ApiException catch (e) {
      if (!silent) _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cambia el estado. El backend valida la transición (flujo normal
  /// y cancelación) y dispara puntos/notificación al pasar a DELIVERED.
  /// Devuelve true si se aplicó; si no, [errorMessage] trae el motivo.
  Future<bool> updateStatus(String orderId, OrderStatus status) async {
    if (_token == null || !_isAdmin) return false;

    _busyOrderId = orderId;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiClient.patch(
        '/orders/$orderId/status',
        token: _token,
        body: {'status': status.apiValue},
      );
      // La respuesta del PATCH no trae los datos del cliente poblados,
      // así que recargamos la lista completa.
      await fetchOrders(silent: true);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      // Pudo cambiar en otro lado (el cliente canceló, otro admin...).
      await fetchOrders(silent: true);
      return false;
    } finally {
      _busyOrderId = null;
      notifyListeners();
    }
  }

  /// Valida el pago por transferencia: el pedido pasa a Confirmado y el
  /// cliente recibe la notificación. Devuelve true si se aplicó.
  Future<bool> validatePayment(String orderId) => _paymentAction(orderId, 'validate');

  /// Invalida el pago (comprobante falso): el pedido se cancela solo y
  /// el cliente recibe la notificación. Devuelve true si se aplicó.
  Future<bool> invalidatePayment(String orderId) => _paymentAction(orderId, 'invalidate');

  Future<bool> _paymentAction(String orderId, String action) async {
    if (_token == null || !_isAdmin) return false;

    _busyOrderId = orderId;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiClient.patch('/orders/$orderId/payment/$action', token: _token);
      await fetchOrders(silent: true);
      return true;
    } on ApiException catch (e) {
      _errorMessage = _translatePaymentError(e.message);
      // Pudo cambiar en otro lado (el cliente reemplazó el comprobante...).
      await fetchOrders(silent: true);
      return false;
    } finally {
      _busyOrderId = null;
      notifyListeners();
    }
  }

  String _translatePaymentError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('no payment proof')) {
      return 'Este pedido no tiene un comprobante pendiente de revisión.';
    }
    if (lower.contains('already closed')) {
      return 'El pedido ya está cerrado y no se puede modificar.';
    }
    if (lower.contains('was cancelled')) {
      return 'Este pedido ya fue cancelado.';
    }
    if (lower.contains('changed in the meantime')) {
      return 'El pedido cambió mientras lo revisabas. Revísalo de nuevo.';
    }
    return message;
  }

  /// Elimina un pedido (el backend solo permite los CANCELLED).
  Future<bool> deleteOrder(String orderId) async {
    if (_token == null || !_isAdmin) return false;

    _busyOrderId = orderId;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiClient.delete('/orders/$orderId', token: _token);
      _orders.removeWhere((o) => o.id == orderId);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _busyOrderId = null;
      notifyListeners();
    }
  }
}
