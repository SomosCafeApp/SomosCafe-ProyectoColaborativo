import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../product_detail/customization_summary.dart';

class OrderSummaryCard extends StatelessWidget {
  final CartProvider cart;
  final double subtotal;
  final double shipping;
  final double discount;
  final double total;
  final String Function(double) formatMoney;

  const OrderSummaryCard({
    super.key,
    required this.cart,
    required this.subtotal,
    required this.shipping,
    required this.discount,
    required this.total,
    required this.formatMoney,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final subtleColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    Widget summaryRow(String label, String value,
            {bool bold = false, Color? color}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: bold ? 16 : 14,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  color: textColor,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: bold ? 18 : 14,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  color: color ?? textColor,
                ),
              ),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF332B1E) : const Color(0xFFFDF6E2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFF3E5AB),
        ),
      ),
      child: Column(
        children: [
          for (final line in cart.lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${line.quantity}×',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          line.product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        CustomizationSummary(
                          customization: line.customization,
                          color: subtleColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatMoney(line.lineTotal),
                    style: TextStyle(fontSize: 13, color: subtleColor),
                  ),
                ],
              ),
            ),
          const Divider(height: 20),
          summaryRow('Subtotal', formatMoney(subtotal)),
          summaryRow('Envío', shipping == 0 ? 'Gratis' : formatMoney(shipping)),
          summaryRow(
              'Descuento', discount == 0 ? '\$0' : '-${formatMoney(discount)}'),
          const Divider(height: 20),
          summaryRow('Total', formatMoney(total),
              bold: true, color: AppColors.primary),
        ],
      ),
    );
  }
}