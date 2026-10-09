import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/favorites_guard.dart';
import '../../models/product_model.dart';
import '../../providers/favorites_provider.dart';

/// Barra superior del detalle: "Volver" y botón de favorito.
class ProductDetailHeader extends StatelessWidget {
  final Product product;

  const ProductDetailHeader({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final isFav = context.watch<FavoritesProvider>().isFavorite(product);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                Icon(Icons.arrow_back_ios_new, size: 16, color: textColor),
                const SizedBox(width: 4),
                Text('Volver', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFav ? Colors.red : subtitleColor,
            ),
            onPressed: () => FavoritesGuard.toggleFavorite(context, product),
          ),
        ],
      ),
    );
  }
}
