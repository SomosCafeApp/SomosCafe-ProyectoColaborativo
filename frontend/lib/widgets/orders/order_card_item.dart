import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order.dart';
import '../product_detail/customization_summary.dart';

class OrderCardItem extends StatelessWidget {
  final Order order;
  final bool isExpanded;
  final VoidCallback onTap;

  /// null cuando el pedido ya no se puede cancelar (fuera de estado o
  /// de los 10 minutos). El contador lo refresca OrdersPage cada segundo.
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

  String get _orderNumber => '#${order.shortId}';

  String get _formattedDate {
    final date = order.createdAt;
    if (date == null) return '';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year}, $hour:$minute';
  }

  String _money(double v) => '\$${v.toStringAsFixed(0)} COP';

  String get _remainingText {
    final d = order.cancelRemaining;
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color get _statusColor {
    switch (order.status) {
      case OrderStatus.delivered:
        return const Color(0xFF4CAF50);
      case OrderStatus.cancelled:
        return const Color(0xFFE53935);
      case OrderStatus.ready:
      case OrderStatus.outForDelivery:
        return const Color(0xFF2196F3);
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
      case OrderStatus.pending:
        return Icons.hourglass_empty_rounded;
      case OrderStatus.confirmed:
        return Icons.thumb_up_alt_outlined;
      case OrderStatus.preparing:
        return Icons.coffee_maker_outlined;
      case OrderStatus.ready:
        return Icons.shopping_bag_outlined;
      case OrderStatus.outForDelivery:
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
    final statusColor = _statusColor;
    const red = Color(0xFFE53935);

    Widget infoRow(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 14, color: subtitleColor),
              const SizedBox(width: 6),
              Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: subtitleColor))),
            ],
          ),
        );

    Widget amountRow(String label, String value, {bool bold = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 13, fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: bold ? textColor : subtitleColor)),
              Text(value,
                  style: TextStyle(
                      fontSize: bold ? 14 : 13,
                      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                      color: bold ? primaryBrown : textColor)),
            ],
          ),
        );

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
                      decoration: BoxDecoration(color: surfaceSubtle, borderRadius: BorderRadius.circular(14)),
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
                          Text('$_formattedDate · ${order.deliveryType.label}',
                              style: TextStyle(fontSize: 12, color: subtitleColor)),
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
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
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
                          _money(order.total),
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                        ),
                      ],
                    ),
                  ],
                ),

                // Cancelación: visible sin expandir mientras dure la ventana.
                if (onCancel != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 16, color: subtitleColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Puedes cancelar durante $_remainingText',
                          style: TextStyle(fontSize: 12, color: subtitleColor),
                        ),
                      ),
                      SizedBox(
                        height: 34,
                        child: OutlinedButton.icon(
                          onPressed: isCancelling ? null : onCancel,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: red),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                          ),
                          icon: isCancelling
                              ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.close_rounded, size: 14, color: red),
                          label: const Text('Cancelar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: red)),
                        ),
                      ),
                    ],
                  ),
                ],

                // Sección desplegable
                if (isExpanded) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(height: 1),
                  ),
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${item.quantity}×',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryBrown)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: TextStyle(fontSize: 13, color: textColor)),
                                  CustomizationSummary(customization: item.customization, color: subtitleColor),
                                  if (item.hasDiscount && item.promotionName.isNotEmpty)
                                    Text(
                                      '${item.promotionName} · -${_money(item.discount)}',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(_money(item.netSubtotal), style: TextStyle(fontSize: 13, color: subtitleColor)),
                          ],
                        ),
                      )),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  amountRow('Subtotal', _money(order.subtotal)),
                  amountRow('Envío', order.shippingCost == 0 ? 'Gratis' : _money(order.shippingCost)),
                  amountRow('Descuento', order.discount == 0 ? '\$0' : '-${_money(order.discount)}'),
                  const SizedBox(height: 4),
                  amountRow('Total', _money(order.total), bold: true),
                  const SizedBox(height: 6),
                  infoRow(
                    order.deliveryType == DeliveryType.pickup ? Icons.storefront_outlined : Icons.delivery_dining_outlined,
                    'Tipo de entrega: ${order.deliveryType.label}',
                  ),
                  if (order.recipientName.isNotEmpty || order.recipientPhone.isNotEmpty)
                    infoRow(
                      Icons.person_outline,
                      'Recibe: ${[order.recipientName, order.recipientPhone].where((s) => s.isNotEmpty).join(' · ')}',
                    ),
                  if (order.addressText.isNotEmpty)
                    infoRow(
                      Icons.location_on_outlined,
                      order.addressLabel.isNotEmpty ? '${order.addressLabel}: ${order.addressText}' : order.addressText,
                    ),
                  if (order.paymentTitle.isNotEmpty)
                    infoRow(
                      Icons.credit_card_rounded,
                      'Pago: ${[order.paymentTitle, order.paymentDetail].where((s) => s.isNotEmpty).join(' · ')}',
                    ),
                  if (order.notes.isNotEmpty) infoRow(Icons.sticky_note_2_outlined, 'Nota: ${order.notes}'),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
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
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
