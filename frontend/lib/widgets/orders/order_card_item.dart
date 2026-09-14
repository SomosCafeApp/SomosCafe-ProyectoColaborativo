import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../pages/orders_page.dart';

class OrderCardItem extends StatelessWidget {
  final OrderItemModel order;
  final bool isExpanded;
  final VoidCallback onTap;

  const OrderCardItem({
    super.key,
    required this.order,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = theme.cardTheme.color ?? (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surfaceSubtle = isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;
    final primaryBrown = AppColors.primary;
    final isDelivered = order.status == 'Entregado';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera de la tarjeta
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: surfaceSubtle,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.inventory_2_outlined, color: primaryBrown, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pedido ${order.orderNumber}',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                          ),
                          const SizedBox(height: 2),
                          Text(order.date, style: TextStyle(fontSize: 12, color: subtitleColor)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDelivered
                                    ? (isDark ? const Color(0xFF1E3326) : const Color(0xFFE8F5E9))
                                    : (isDark ? const Color(0xFF381C1C) : const Color(0xFFFFEBEE)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isDelivered ? Icons.check_circle_outline : Icons.cancel_outlined,
                                    size: 12,
                                    color: isDelivered ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    order.status,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isDelivered ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                              color: subtitleColor,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.total,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                        ),
                      ],
                    ),
                  ],
                ),

                // Sección desplegable
                if (isExpanded) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(height: 1),
                  ),
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text('${item.quantity}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryBrown)),
                                const SizedBox(width: 8),
                                Text(item.name, style: TextStyle(fontSize: 13, color: textColor)),
                              ],
                            ),
                            Text(item.price, style: TextStyle(fontSize: 13, color: subtitleColor)),
                          ],
                        ),
                      )),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
                      Text(order.total, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryBrown)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: subtitleColor),
                      const SizedBox(width: 4),
                      Text(order.address, style: TextStyle(fontSize: 12, color: subtitleColor)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.credit_card_rounded, size: 14, color: subtitleColor),
                      const SizedBox(width: 4),
                      Text(order.paymentMethod, style: TextStyle(fontSize: 12, color: subtitleColor)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Productos del pedido ${order.orderNumber} agregados al carrito'),
                            backgroundColor: primaryBrown,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryBrown.withAlpha(100)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
                      ),
                      icon: Icon(Icons.refresh_rounded, size: 16, color: primaryBrown),
                      label: Text(
                        'Pedir de nuevo',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryBrown),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}