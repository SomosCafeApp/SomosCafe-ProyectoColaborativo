import 'package:flutter/material.dart';

// --- MODELOS DE DATOS ---

class OrderItem {
  final int quantity;
  final String name;
  final String size;
  final String price;

  OrderItem({
    required this.quantity,
    required this.name,
    this.size = '',
    required this.price,
  });
}

class Order {
  final String id;
  final String date;
  final String status; // 'Entregado', 'Cancelado', etc.
  final String totalPrice;
  final String address;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.date,
    required this.status,
    required this.totalPrice,
    required this.address,
    required this.items,
  });
}

// --- VISTA PRINCIPAL ---

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  // Lista de pedidos con sus detalles completos
  final List<Order> _orders = [
    Order(
      id: '#10042',
      date: '28 ago 2026, 10:15',
      status: 'Entregado',
      totalPrice: '\$33.500 COP',
      address: 'Cra 7 #15-23, Garzón',
      items: [
        OrderItem(quantity: 2, name: 'Cappuccino', size: 'Medium', price: '\$24.000 COP'),
        OrderItem(quantity: 1, name: 'Croissant de Almendra', price: '\$9.500 COP'),
      ],
    ),
    Order(
      id: '#10039',
      date: '24 ago 2026, 16:42',
      status: 'Entregado',
      totalPrice: '\$31.000 COP',
      address: 'Cra 7 #15-23, Garzón',
      items: [
        OrderItem(quantity: 1, name: 'Americano', size: 'Large', price: '\$10.000 COP'),
        OrderItem(quantity: 2, name: 'Tarta de Queso', price: '\$21.000 COP'),
      ],
    ),
    Order(
      id: '#10035',
      date: '19 ago 2026, 08:30',
      status: 'Entregado',
      totalPrice: '\$14.500 COP',
      address: 'Cra 7 #15-23, Garzón',
      items: [
        OrderItem(quantity: 1, name: 'Latte Cold Brew', size: 'Medium', price: '\$14.500 COP'),
      ],
    ),
    Order(
      id: '#10029',
      date: '12 ago 2026, 14:10',
      status: 'Cancelado',
      totalPrice: '\$16.000 COP',
      address: 'Cra 7 #15-23, Garzón',
      items: [
        OrderItem(quantity: 1, name: 'Mochaccino', size: 'Large', price: '\$10.500 COP'),
        OrderItem(quantity: 1, name: 'Muffin de Chispas', price: '\$5.500 COP'),
      ],
    ),
  ];

  // Ningún pedido abierto por defecto
  String? _expandedOrderId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryBrown = theme.colorScheme.primary;
    final bgCanvas = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = textColor.withOpacity(0.6);

    return Scaffold(
      backgroundColor: bgCanvas,
      body: Column(
        children: [
          // Header Superior
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
            width: double.infinity,
            color: primaryBrown,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Historial de Pedidos',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Consulta tus compras anteriores',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de Pedidos
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              physics: const BouncingScrollPhysics(),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                final isExpanded = _expandedOrderId == order.id;

                return _buildOrderCard(
                  order: order,
                  isExpanded: isExpanded,
                  cardColor: cardColor,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  isDark: isDark,
                  onTap: () {
                    setState(() {
                      _expandedOrderId = isExpanded ? null : order.id;
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

  Widget _buildOrderCard({
    required Order order,
    required bool isExpanded,
    required Color cardColor,
    required Color textColor,
    required Color subtitleColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final isDelivered = order.status == 'Entregado';

    final badgeBg = isDelivered
        ? (isDark ? const Color(0xFF1E3A22) : const Color(0xFFE8F5E9))
        : (isDark ? const Color(0xFF3E1F23) : const Color(0xFFFFEBEE));

    final badgeText = isDelivered
        ? (isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32))
        : (isDark ? const Color(0xFFFF6B6B) : const Color(0xFFE53935));

    final iconBadgeBg = isDark ? const Color(0xFF3D2E1A) : const Color(0xFFFFF8E1);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Cabecera del pedido
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconBadgeBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Color(0xFFB8860B),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pedido ${order.id}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.date,
                          style: TextStyle(
                            fontSize: 12,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isDelivered ? Icons.check_circle_outline : Icons.cancel_outlined,
                              size: 13,
                              color: badgeText,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              order.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: badgeText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            order.totalPrice,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            size: 18,
                            color: subtitleColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Contenido desplegable
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(
                height: 1,
                color: isDark ? Colors.white12 : const Color(0xFFF0F0F0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Items del pedido
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white10 : const Color(0xFFF5F5F5),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${item.quantity}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: subtitleColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: 13, color: textColor),
                                  children: [
                                    TextSpan(
                                      text: item.name,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    if (item.size.isNotEmpty)
                                      TextSpan(
                                        text: ' (${item.size})',
                                        style: TextStyle(color: subtitleColor),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            Text(
                              item.price,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      )),

                  const SizedBox(height: 12),

                  // Fila del Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: subtitleColor,
                        ),
                      ),
                      Text(
                        order.totalPrice,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Dirección de entrega
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Color(0xFFD32F2F),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        order.address,
                        style: TextStyle(
                          fontSize: 12,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Botón "Pedir de nuevo"
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark ? Colors.white24 : const Color(0xFFE5DDD3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {},
                      icon: Icon(
                        Icons.refresh_rounded,
                        size: 16,
                        color: textColor,
                      ),
                      label: Text(
                        'Pedir de nuevo',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}