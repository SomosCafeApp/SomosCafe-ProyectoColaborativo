import 'package:flutter/material.dart';

import '../../animations/animations.dart';
import '../../core/constants/app_colors.dart';

/// Barra inferior con el botón "Agregar al Carrito". Si el producto
/// fue ocultado del menú, el botón se deshabilita. El total cambia con
/// una transición suave cuando el cliente ajusta su pedido.
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
    final label = isAvailable ? 'Agregar al Carrito (\$${total.toStringAsFixed(0)} COP)' : 'No disponible';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? (isDark ? AppColors.darkSurface : AppColors.lightSurface),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: PressScale(
          scale: 0.985,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.35),
              elevation: 4,
              shadowColor: AppColors.primary.withValues(alpha: 0.45),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            onPressed: isAvailable ? onAdd : null,
            icon: Icon(isAvailable ? Icons.shopping_bag_rounded : Icons.block_rounded, color: Colors.white, size: 20),
            label: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(anim),
                  child: child,
                ),
              ),
              child: Text(
                label,
                key: ValueKey(label),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
