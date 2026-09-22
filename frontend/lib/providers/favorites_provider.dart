import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';

/// Favoritos conectados al backend (GET/POST/DELETE /api/favorites).
///
/// Mientras no hay sesión, funciona solo en memoria (se pierde al
/// cerrar la app); en cuanto el usuario inicia sesión, [updateAuth]
/// carga sus favoritos reales guardados en la base de datos.
class FavoritesProvider extends ChangeNotifier {
  List<Product> _favorites = [];
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get favorites => _favorites;
  int get itemCount => _favorites.length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool isFavorite(Product product) {
    return _favorites.any((item) => item.id == product.id);
  }

  /// Llamado por el ChangeNotifierProxyProvider cada vez que cambia
  /// la sesión (login, logout o restauración automática al abrir la app).
  void updateAuth(String? token) {
    final wasLoggedIn = _token != null;
    _token = token;

    if (token != null && !wasLoggedIn) {
      fetchFavorites();
    } else if (token == null && wasLoggedIn) {
      _favorites = [];
      notifyListeners();
    }
  }

  Future<void> fetchFavorites() async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiClient.get('/favorites', token: _token);
      final raw = data['favorites'] as List? ?? [];
      _favorites = raw
          .where((f) => f['productId'] is Map)
          .map((f) => Product.fromJson(f['productId'] as Map<String, dynamic>))
          .toList();
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(Product product) async {
    final wasFavorite = isFavorite(product);

    // Actualización optimista.
    if (wasFavorite) {
      _favorites.removeWhere((item) => item.id == product.id);
    } else {
      _favorites.add(product);
    }
    notifyListeners();

    if (_token == null) return; // invitado: solo memoria local

    try {
      if (wasFavorite) {
        await ApiClient.delete('/favorites/${product.id}', token: _token);
      } else {
        await ApiClient.post('/favorites', token: _token, body: {
          'productId': product.id,
        });
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      // Revertimos el cambio optimista si el backend lo rechazó.
      if (wasFavorite) {
        _favorites.add(product);
      } else {
        _favorites.removeWhere((item) => item.id == product.id);
      }
      notifyListeners();
    }
  }

  void clearFavorites() {
    _favorites = [];
    notifyListeners();
  }
}
