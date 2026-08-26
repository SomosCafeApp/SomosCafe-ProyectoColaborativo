import 'package:flutter/material.dart';
import '../../data/models/product.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<Product> _favorites = [];

  List<Product> get favorites => _favorites;

  int get itemCount => _favorites.length;

  // Comprobar comparando IDs explícitamente
  bool isFavorite(Product product) {
    return _favorites.any((item) => item.id.toString() == product.id.toString());
  }

  void toggleFavorite(Product product) {
    final index = _favorites.indexWhere((item) => item.id.toString() == product.id.toString());
    
    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(product);
    }
    notifyListeners(); // Notifica a FavoritesPage para redibujar el contador
  }

  void clearFavorites() {
    _favorites.clear();
    notifyListeners();
  }
}