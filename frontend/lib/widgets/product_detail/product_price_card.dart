import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/product_model.dart';
import 'custom_section_card.dart';
import 'quantity_counter.dart';

/// Tarjeta con el precio total (con descuento y precio tachado si hay
/// promoción) y el contador de cantidad.
class ProductPriceCard extends StatelessWidget {
  final Product product;
  final double totalPrice;
  final double originalPrice;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const ProductPriceCard({
    super.key,
    required this.product,
    required this.totalPrice,
    required this.originalPrice,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return CustomSectionCard(
      cardColor: theme.cardTheme.color ?? (isDark ? AppColors.darkSurface : AppColors.lightSurface),
      textColor: textColor,
      mutedColor: subtitleColor.withAlpha(150),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product.hasDiscount)
                Row(
                  children: [
                    Text(
                      '\$${originalPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: subtitleColor,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentYellow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        product.promotionLabel ?? 'Promo',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              Text(
                '\$${totalPrice.toStringAsFixed(0)} COP',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
            ],
          ),
          QuantityCounter(
            value: quantity,
            counterBtnBg: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
            textColor: textColor,
            onIncrement: onIncrement,
            onDecrement: onDecrement,
          ),
        ],
      ),
    );
  }
}
