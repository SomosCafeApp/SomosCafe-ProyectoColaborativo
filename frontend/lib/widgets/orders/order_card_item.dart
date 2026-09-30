import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order.dart';

class OrderCardItem extends StatelessWidget {
  final Order order;
  final bool isExpanded;
  final VoidCallback onTap;
  // null cuando el pedido ya no se puede cancelar (isCancellable == false).
  final VoidCallback? onCancel;
  final VoidCallback onReorder;
  final bool isCancelling;

  const OrderCardItem({
    super.key,
    required this.order,
    required this.isExpanded,
    required this.onTap,
    required this.onReorder,
    this.onCancel,
    this.isCancelling = false,
  });

  String get _orderNumber {
    final id = order.id;
    final shortId = id.length >= 6 ? id.substring(id.length - 6) : id;
    return '#${shortId.toUpperCase()}';
  }

  String get _formattedDate {
    final date = order.createdAt;
    if (date == null) return '';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year}, $hour:$minute';
  }

  String get _totalFormatted => '\$${order.total.toStringAsFixed(0)} COP';

  Color _statusColor(bool isDark) {
    switch (order.status) {
      case OrderStatus.delivered:
        return const Color(0xFF4CAF50);
      case OrderStatus.cancelled:
        return const Color(0xFFE53935);
      default:
        return AppColors.primary;
    }
  }

  IconData get _statusIcon {
    switch (order.status) {
      case OrderStatus.delivered:
        return Icons.check_circle_outline;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
      default:
        return Icons.local_shipping_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = theme.cardTheme.color ?? (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surfaceSubtle = isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;
    final primaryBrown = AppColors.primary;
    final statusColor = _statusColor(isDark);

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
                            'Pedido $_orderNumber',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                          ),
                          const SizedBox(height: 2),
                          Text(_formattedDate, style: TextStyle(fontSize: 12, color: subtitleColor)),
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
                                color: statusColor.withAlpha(isDark ? 40 : 25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_statusIcon, size: 12, color: statusColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    order.status.label,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
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
                          _totalFormatted,
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
                            Expanded(
                              child: Row(
                                children: [
                                  Text('${item.quantity}',
                                      style: TextStyle(
                                          fontSize: 13, fontWeight: FontWeight.bold, color: primaryBrown)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(item.name,
                                        style: TextStyle(fontSize: 13, color: textColor),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                            ),
                            Text('\$${item.subtotal.toStringAsFixed(0)} COP',
                                style: TextStyle(fontSize: 13, color: subtitleColor)),
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
                      Text(_totalFormatted,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryBrown)),
                    ],
                  ),
                  if (order.addressText.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: subtitleColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(order.addressText,
                              style: TextStyle(fontSize: 12, color: subtitleColor)),
                        ),
                      ],
                    ),
                  ],
                  if (order.notes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.credit_card_rounded, size: 14, color: subtitleColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(order.notes, style: TextStyle(fontSize: 12, color: subtitleColor)),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 42,
                          child: OutlinedButton.icon(
                            onPressed: onReorder,
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
                      ),
                      if (onCancel != null) ...[
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 42,
                          child: OutlinedButton(
                            onPressed: isCancelling ? null : onCancel,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE53935)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
                            ),
                            child: isCancelling
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.close_rounded, size: 16, color: Color(0xFFE53935)),
                          ),
                        ),
                      ],
                    ],
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
