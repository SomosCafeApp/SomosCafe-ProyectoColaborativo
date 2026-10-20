import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

import '../../animations/animations.dart';
class CartEmptyState extends StatelessWidget {
  final Color primaryBrown;
  final VoidCallback? onExploreMenu;

  const CartEmptyState({
    super.key,
    required this.primaryBrown,
    this.onExploreMenu,
  });

  @override
  Widget build(BuildContext context) => SoftFadeIn(child: _buildSoft(context));

  Widget _buildSoft(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = theme.colorScheme.onSurface;

    // Mismos colores que el resto de estados vacíos (p. ej. el buscador):
    // círculo más claro que el fondo y ícono beige en modo oscuro.
    final circleBg = isDark
        ? AppColors.darkSurfaceSubtle
        : primaryBrown.withValues(alpha: 0.15);
    final iconColor = isDark ? const Color(0xFFD4BBA5) : primaryBrown;
    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 96,
            height: 118,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: circleBg,
                  ),
                  child: Icon(
                    Icons.coffee_outlined,
                    size: 40,
                    color: iconColor,
                  ),
                ),
                Positioned(
                  top: 0,
                  child: CoffeeSteam(size: 36, color: iconColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Tu carrito está vacío',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Añade productos para continuar',
            style: TextStyle(
              fontSize: 14,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onExploreMenu,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBrown,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Explorar Menú',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}