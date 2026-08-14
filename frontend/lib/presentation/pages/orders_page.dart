import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/order_provider.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final orders = orderProvider.orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pedidos'),
      ),
      body: orders.isEmpty
          ? const Center(
              child: Text(
                'Aún no has realizado pedidos',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: const Icon(Icons.receipt_long, color: Color(0xFF4E342E)),
                    title: Text('Pedido #${order.id.substring(order.id.length - 6)}'),
                    subtitle: Text(
                      '${order.date.day}/${order.date.month}/${order.date.year} - \$${order.total.toStringAsFixed(0)} COP',
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dirección: ${order.address}', style: const TextStyle(fontWeight: FontWeight.w500)),
                            Text('Pago: ${order.paymentMethod}'),
                            const Divider(),
                            ...order.items.map((item) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2.0), // <-- Corrección aquí
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(item.name),
                                      Text('\$${item.price.toStringAsFixed(0)} COP'),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}