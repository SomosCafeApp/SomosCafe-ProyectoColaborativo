import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../product_detail/customization_summary.dart';

/// Resumen del pedido antes de confirmar: productos con su
/// personalización y promoción, subtotal, envío, descuento y total.
/// Los montos son informativos; el backend recalcula al confirmar.
class OrderSummaryCard extends StatelessWidget {
  final List<CartLine> lines;
  final double subtotal;
  final double shipping;
  final double discount;
  final double total;

  const OrderSummaryCard({
    super.key,
    required this.lines,
    required this.subtotal,
    required this.shipping,
    required this.discount,
    required this.total,
  });

  String _money(double value) => '\$${value.toStringAsFixed(0)} COP';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final subtleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF332B1E) : const Color(0xFFFDF6E2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFF3E5AB)),
      ),
      child: Column(
        children: [
          for (final line in lines) _LineRow(line: line, textColor: textColor, subtleColor: subtleColor, money: _money),
          const Divider(height: 20),
          _AmountRow('Subtotal', _money(subtotal), textColor: textColor),
          _AmountRow('Envío', shipping == 0 ? 'Gratis' : _money(shipping), textColor: textColor),
          _AmountRow('Descuento', discount == 0 ? '\$0' : '-${_money(discount)}', textColor: textColor),
          const Divider(height: 20),
          _AmountRow('Total', _money(total), textColor: textColor, bold: true, valueColor: AppColors.primary),
        ],
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  final CartLine line;
  final Color textColor;
  final Color subtleColor;
  final String Function(double) money;

  const _LineRow({
    required this.line,
    required this.textColor,
    required this.subtleColor,
    required this.money,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${line.quantity}×', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.product.name, style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                CustomizationSummary(customization: line.customization, color: subtleColor),
                if (line.hasDiscount && (line.promotionName ?? '').isNotEmpty)
                  Text(
                    line.promotionName!,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(money(line.lineTotal), style: TextStyle(fontSize: 13, color: subtleColor)),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;
  final bool bold;
  final Color? valueColor;

  const _AmountRow(this.label, this.value, {required this.textColor, this.bold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              color: valueColor ?? textColor,
            ),
          ),
        ],
      ),
    );
  }
}
