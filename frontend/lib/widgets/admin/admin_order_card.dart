import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/order.dart';
import '../product_detail/customization_summary.dart';

/// Tarjeta de un pedido en el panel admin: resumen arriba y, al
/// expandir, cliente, productos con personalización, montos, entrega,
/// pago y acciones de estado.
class AdminOrderCard extends StatelessWidget {
  final Order order;
  final bool isExpanded;
  final bool isBusy;
  final VoidCallback onTap;
  final ValueChanged<OrderStatus> onChangeStatus;
  final VoidCallback onDelete;

  const AdminOrderCard({
    super.key,
    required this.order,
    required this.isExpanded,
    required this.isBusy,
    required this.onTap,
    required this.onChangeStatus,
    required this.onDelete,
  });

  String _money(double v) => '\$${v.toStringAsFixed(0)} COP';

  String get _formattedDate {
    final d = order.createdAt;
    if (d == null) return '';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}, ${two(d.hour)}:${two(d.minute)}';
  }

  String get _paymentStatusLabel {
    switch (order.paymentStatus) {
      case 'PAID':
        return 'Pagado';
      case 'FAILED':
        return 'Fallido';
      case 'REFUNDED':
        return 'Reembolsado';
      default:
        return 'Pendiente de pago';
    }
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = theme.cardTheme.color ?? (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final statusColor = _statusColor(order.status);
    final primary = AppColors.primary;

    Widget infoRow(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 15, color: subtitleColor),
              const SizedBox(width: 6),
              Expanded(child: Text(text, style: TextStyle(fontSize: 12.5, color: textColor))),
            ],
          ),
        );

    Widget amountRow(String label, String value, {bool bold = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: bold ? textColor : subtitleColor)),
              Text(value, style: TextStyle(fontSize: bold ? 14 : 13, fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: bold ? primary : textColor)),
            ],
          ),
        );

    final customerTitle = order.customerName.isNotEmpty ? order.customerName : 'Cliente';
    final nextOptions = order.status.nextOptions(order.deliveryType);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(isDark ? 40 : 8), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pedido #${order.shortId}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
                          const SizedBox(height: 2),
                          Text(customerTitle, style: TextStyle(fontSize: 13, color: textColor)),
                          Text('$_formattedDate · ${order.deliveryType.label}', style: TextStyle(fontSize: 12, color: subtitleColor)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(isDark ? 40 : 25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(order.status.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
                        ),
                        const SizedBox(height: 4),
                        Text(_money(order.total), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                        Icon(isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: subtitleColor, size: 20),
                      ],
                    ),
                  ],
                ),

                if (isExpanded) ...[
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),

                  // Cliente
                  Text('Cliente', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subtitleColor)),
                  infoRow(Icons.person_outline, customerTitle),
                  if (order.customerEmail.isNotEmpty) infoRow(Icons.mail_outline, order.customerEmail),
                  if (order.customerPhone.isNotEmpty) infoRow(Icons.phone_outlined, order.customerPhone),

                  const SizedBox(height: 12),
                  Text('Productos', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subtitleColor)),
                  const SizedBox(height: 4),
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${item.quantity}×', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primary)),
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

                  const SizedBox(height: 12),
                  Text('Entrega', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subtitleColor)),
                  infoRow(
                    order.deliveryType == DeliveryType.pickup ? Icons.storefront_outlined : Icons.delivery_dining_outlined,
                    order.deliveryType.label,
                  ),
                  if (order.recipientName.isNotEmpty) infoRow(Icons.badge_outlined, 'Recibe: ${order.recipientName}'),
                  if (order.recipientPhone.isNotEmpty) infoRow(Icons.phone_in_talk_outlined, order.recipientPhone),
                  if (order.addressText.isNotEmpty)
                    infoRow(Icons.location_on_outlined, order.addressLabel.isNotEmpty ? '${order.addressLabel}: ${order.addressText}' : order.addressText),
                  if (order.notes.isNotEmpty) infoRow(Icons.sticky_note_2_outlined, 'Nota: ${order.notes}'),

                  const SizedBox(height: 12),
                  Text('Pago', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subtitleColor)),
                  infoRow(
                    Icons.credit_card_rounded,
                    [
                      if (order.paymentTitle.isNotEmpty) order.paymentTitle else 'Sin método registrado',
                      if (order.paymentDetail.isNotEmpty) order.paymentDetail,
                      _paymentStatusLabel,
                    ].join(' · '),
                  ),

                  // Acciones
                  if (nextOptions.isNotEmpty || order.status == OrderStatus.cancelled) ...[
                    const SizedBox(height: 16),
                    if (isBusy)
                      const Center(child: Padding(padding: EdgeInsets.all(6), child: CircularProgressIndicator()))
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final next in nextOptions)
                            next == OrderStatus.cancelled
                                ? OutlinedButton.icon(
                                    onPressed: () => onChangeStatus(next),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFFE53935)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    ),
                                    icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFFE53935)),
                                    label: const Text('Cancelar', style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold)),
                                  )
                                : ElevatedButton(
                                    onPressed: () => onChangeStatus(next),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    ),
                                    child: Text('Pasar a ${next.label}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                          if (order.status == OrderStatus.cancelled)
                            OutlinedButton.icon(
                              onPressed: onDelete,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFE53935)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFE53935)),
                              label: const Text('Eliminar', style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
