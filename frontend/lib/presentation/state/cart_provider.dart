import 'package:flutter/material.dart';
import '../../data/models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => _items;

  double get total => _items.fold(0, (sum, item) => sum + item.price);

  void addToCart(Product product) {
    _items.add(product);
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _items.remove(product);
    notifyListeners();
  }

  void removeSingleItem(Product product) {
  final index = _items.indexWhere((item) => item.id == product.id);
  if (index >= 0) {
    _items.removeAt(index);
    notifyListeners();
  }
}

  // Agregamos esto para limpiar el carrito tras comprar
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

