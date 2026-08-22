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

  // Agregamos esto para limpiar el carrito tras comprar
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}