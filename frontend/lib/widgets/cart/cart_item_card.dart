import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../product_detail/customization_summary.dart';

import '../../animations/animations.dart';
class CartItemCard extends StatelessWidget {
  final CartLine line;
  final Color primaryBrown;
  final Color cardBgColor;
  final VoidCallback onAdd;
  final VoidCallback onRemoveSingle;
  final VoidCallback onDeleteAll;

  const CartItemCard({
    super.key,
    required this.line,
    required this.primaryBrown,
    required this.cardBgColor,
    required this.onAdd,
    required this.onRemoveSingle,
    required this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) => SoftFadeIn(child: _buildSoft(context));

  Widget _buildSoft(BuildContext context) {
    final product = line.product;
    final quantity = line.quantity;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final counterBgColor = isDark
        ? AppColors.darkSurfaceSubtle
        : AppColors.lightSurfaceSubtle;

    return Container(
      key: ValueKey(line.id),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              product.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: primaryBrown.withOpacity(0.1),
                  child: Icon(Icons.coffee, color: primaryBrown),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      onPressed: onDeleteAll,
                    ),
                  ],
                ),
                // Con personalización se muestran sus opciones; si va
                // con las de por defecto, la descripción del producto.
                if (line.customization.isDefault)
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  CustomizationSummary(
                    customization: line.customization,
                    color: subtitleColor,
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (line.hasDiscount)
                          Text(
                            '\$${line.lineSubtotal.toStringAsFixed(0)} COP',
                            style: TextStyle(
                              fontSize: 11,
                              color: subtitleColor,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          '\$${line.lineTotal.toStringAsFixed(0)} COP',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: line.hasDiscount ? AppColors.primary : textColor,
                          ),
                        ),
                        if (!line.isAvailable)
                          const Text(
                            'No disponible',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE53935)),
                          ),
                        if (line.hasDiscount && (line.promotionName ?? '').isNotEmpty)
                          Text(
                            line.promotionName!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: counterBgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: quantity > 1 ? onRemoveSingle : null,
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text(
                                '-',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: quantity > 1 ? textColor : subtitleColor.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              '$quantity',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                            ),
                          ),
                          InkWell(
                            onTap: onAdd,
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text(
                                '+',
                                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}