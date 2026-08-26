import 'product.dart';

class Order {
  final String id;
  final List<Product> items;
  final double total;
  final DateTime date;
  final String address;
  final String paymentMethod;

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.date,
    required this.address,
    required this.paymentMethod,
  });
}