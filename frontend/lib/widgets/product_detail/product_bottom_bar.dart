import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Barra inferior con el botón "Agregar al Carrito". Si el producto
/// fue ocultado del menú, el botón se deshabilita.
class ProductBottomBar extends StatelessWidget {
  final double total;
  final bool isAvailable;
  final VoidCallback onAdd;

  const ProductBottomBar({
    super.key,
    required this.total,
    required this.isAvailable,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? (isDark ? AppColors.darkSurface : AppColors.lightSurface),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: isAvailable ? onAdd : null,
        child: Text(
          isAvailable ? 'Agregar al Carrito (\$${total.toStringAsFixed(0)} COP)' : 'No disponible',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
