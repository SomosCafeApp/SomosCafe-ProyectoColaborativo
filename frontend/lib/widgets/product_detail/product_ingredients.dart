import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Ingredientes del producto en una línea corta ("Ingredientes: café, leche").
/// No dibuja nada si el producto no tiene ingredientes.
class ProductIngredients extends StatelessWidget {
  final List<String> ingredients;

  const ProductIngredients({super.key, required this.ingredients});

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Ingredientes: ',
              style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
            ),
            TextSpan(text: ingredients.join(', ')),
          ],
        ),
        style: TextStyle(fontSize: 12.5, color: subtitleColor, height: 1.35),
      ),
    );
  }
}
