import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';

/// Una línea del carrito: producto + cantidad.
class CartLine {
  final Product product;
  final int quantity;
  CartLine({required this.product, required this.quantity});
}

/// Carrito conectado al backend (GET/POST/PUT/DELETE /api/cart).
///
/// Mientras no hay sesión, funciona en memoria (carrito de invitado)
/// para no romper la experiencia de navegar el menú sin loguearse.
/// En cuanto el usuario inicia sesión, [updateAuth] dispara la carga
/// del carrito real guardado en la base de datos.
class CartProvider extends ChangeNotifier {
  List<CartLine> _lines = [];
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<CartLine> get lines => _lines;

  /// Lista plana con un elemento por unidad, para no tener que tocar
  /// las pantallas que ya agrupan por producto (cart_page.dart, etc.).
  List<Product> get items {
    final flat = <Product>[];
    for (final line in _lines) {
      flat.addAll(List.filled(line.quantity, line.product));
    }
    return flat;
  }

  double get total =>
      _lines.fold(0.0, (sum, l) => sum + (l.product.price * l.quantity));

  /// Llamado por el ChangeNotifierProxyProvider cada vez que cambia
  /// la sesión (login, logout o restauración automática al abrir la app).
  void updateAuth(String? token) {
    final wasLoggedIn = _token != null;
    _token = token;

    if (token != null && !wasLoggedIn) {
      fetchCart();
    } else if (token == null && wasLoggedIn) {
      _lines = [];
      notifyListeners();
    }
  }

  List<CartLine> _parseCart(Map<String, dynamic> cart) {
    final rawItems = cart['items'] as List? ?? [];
    return rawItems
        .where((i) => i['productId'] is Map)
        .map((i) => CartLine(
              product: Product.fromJson(i['productId'] as Map<String, dynamic>),
              quantity: (i['quantity'] as num).toInt(),
            ))
        .toList();
  }

  Future<void> fetchCart() async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiClient.get('/cart', token: _token);
      _lines = _parseCart(data['cart'] as Map<String, dynamic>);
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _addLocal(Product product, int quantity) {
    final idx = _lines.indexWhere((l) => l.product.id == product.id);
    if (idx >= 0) {
      _lines[idx] = CartLine(product: product, quantity: _lines[idx].quantity + quantity);
    } else {
      _lines.add(CartLine(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    // Actualización optimista: se ve al instante en la UI.
    _addLocal(product, quantity);

    if (_token == null) return; // invitado: solo memoria local

    try {
      final data = await ApiClient.post('/cart/items', token: _token, body: {
        'productId': product.id,
        'quantity': quantity,
      });
      _lines = _parseCart(data['cart'] as Map<String, dynamic>);
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      await fetchCart(); // revertimos al estado real del servidor
    }
  }

  Future<void> removeSingleItem(Product product) async {
    final idx = _lines.indexWhere((l) => l.product.id == product.id);
    if (idx < 0) return;

    final newQty = _lines[idx].quantity - 1;

    if (_token == null) {
      if (newQty <= 0) {
        _lines.removeAt(idx);
      } else {
        _lines[idx] = CartLine(product: product, quantity: newQty);
      }
      notifyListeners();
      return;
    }

    try {
      final Map<String, dynamic> data;
      if (newQty <= 0) {
        data = await ApiClient.delete('/cart/items/${product.id}', token: _token);
      } else {
        data = await ApiClient.put('/cart/items/${product.id}', token: _token, body: {
          'quantity': newQty,
        });
      }
      _lines = _parseCart(data['cart'] as Map<String, dynamic>);
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      await fetchCart();
    }
  }

  // Se mantiene por compatibilidad con código que aún llame a esto.
  void removeFromCart(Product product) {
    removeSingleItem(product);
  }

  Future<void> clearCart() async {
    _lines = [];
    notifyListeners();

    if (_token == null) return;

    try {
      await ApiClient.delete('/cart', token: _token);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    }
  }
}
