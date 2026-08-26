import 'package:flutter/material.dart';
import '../../data/models/order.dart';
import '../../data/models/product.dart';

class OrderProvider extends ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => _orders;

  void addOrder({
    required List<Product> items,
    required double total,
    required String address,
    required String paymentMethod,
  }) {
    final newOrder = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: List.from(items),
      total: total,
      date: DateTime.now(),
      address: address,
      paymentMethod: paymentMethod,
    );
    _orders.insert(0, newOrder); // Insertar al inicio para ver el más reciente primero
    notifyListeners();
  }
}