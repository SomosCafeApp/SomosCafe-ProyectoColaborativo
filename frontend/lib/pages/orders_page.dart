import 'package:flutter/material.dart';
import '../widgets/profile/profile_sub_page_header.dart';
import '../widgets/orders/order_card_item.dart';

class OrderItemDetail {
  final int quantity;
  final String name;
  final String price;

  const OrderItemDetail({required this.quantity, required this.name, required this.price});
}

class OrderItemModel {
  final String id;
  final String orderNumber;
  final String date;
  final String total;
  final String status;
  final List items;
  final String address;
  final String paymentMethod;

  const OrderItemModel({
    required this.id,
    required this.orderNumber,
    required this.date,
    required this.total,
    required this.status,
    required this.items,
    required this.address,
    required this.paymentMethod,
  });
}

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State createState() => _OrdersPageState();
}

class _OrdersPageState extends State {
  String? _expandedOrderId;

  final List _orders = const [
    OrderItemModel(
      id: '1',
      orderNumber: '#10042',
      date: '28 ago 2026, 10:15',
      total: '\$33.500 COP',
      status: 'Entregado',
      items: [
        OrderItemDetail(quantity: 2, name: 'Cappuccino (Medium)', price: '\$24.000 COP'),
        OrderItemDetail(quantity: 1, name: 'Croissant de Almendra', price: '\$9.500 COP'),
      ],
      address: 'Cra 7 #15-23, Garzón',
      paymentMethod: 'Tarjeta',
    ),
    OrderItemModel(
      id: '2',
      orderNumber: '#10039',
      date: '24 ago 2026, 16:42',
      total: '\$31.000 COP',
      status: 'Entregado',
      items: [
        OrderItemDetail(quantity: 1, name: 'Latte Mochila', price: '\$15.000 COP'),
        OrderItemDetail(quantity: 2, name: 'Pan de Bono', price: '\$16.000 COP'),
      ],
      address: 'Cra 7 #15-23, Garzón',
      paymentMethod: 'Efectivo',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          const ProfileSubPageHeader(
            title: 'Historial de Pedidos',
            subtitle: 'Consulta tus compras anteriores',
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              physics: const BouncingScrollPhysics(),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return OrderCardItem(
                  order: order,
                  isExpanded: _expandedOrderId == order.id,
                  onTap: () {
                    setState(() {
                      // Solo permite desplegar un pedido a la vez
                      _expandedOrderId = _expandedOrderId == order.id ? null : order.id;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}