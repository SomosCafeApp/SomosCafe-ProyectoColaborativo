import 'package:flutter/material.dart';

import '../models/order.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';

/// Pedidos de TODOS los usuarios para el panel admin.
/// Reutiliza GET /orders, PATCH /orders/:id/status y DELETE /orders/:id
/// (todas protegidas con adminOnly en el backend: aunque alguien
/// llegara a esta pantalla sin ser admin, el servidor lo rechaza).
class AdminOrdersProvider extends ChangeNotifier {
  List<Order> _orders = [];
  String? _token;
  bool _isAdmin = false;

  bool _isLoading = false;
  String? _errorMessage;

  /// Pedido sobre el que hay una acción en curso (cambio de estado o borrado).
  String? _busyOrderId;

  OrderStatus? _statusFilter;
  String _searchQuery = '';

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get busyOrderId => _busyOrderId;
  OrderStatus? get statusFilter => _statusFilter;
  String get searchQuery => _searchQuery;

  /// Pedidos tras aplicar filtro de estado y búsqueda (por número de
  /// pedido, cliente, correo, receptor o teléfono).
  List<Order> get filteredOrders {
    final query = _searchQuery.trim().toLowerCase();

    return _orders.where((o) {
      if (_statusFilter != null && o.status != _statusFilter) return false;
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

  void updateAuth(String? token, bool isAdmin) {
    final wasAdmin = _token != null && _isAdmin;
    _token = token;
    _isAdmin = isAdmin;

    if (token == null || !isAdmin) {
      if (wasAdmin || _orders.isNotEmpty) {
        _orders = [];
        _statusFilter = null;
        _searchQuery = '';
        _errorMessage = null;
        notifyListeners();
      }
    }
  }

  void setStatusFilter(OrderStatus? status) {
    _statusFilter = status;
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
