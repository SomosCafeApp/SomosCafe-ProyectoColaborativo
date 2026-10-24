import 'package:flutter/material.dart';

import '../../animations/animations.dart';
import '../../core/constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../pages/drink_studio_page.dart';
import 'studio_colors.dart';

/// Ícono circular para la tarjeta de una bebida: abre el estudio.
/// Solo se muestra en bebidas disponibles; la compra normal no cambia.
class DrinkStudioButton extends StatelessWidget {
  const DrinkStudioButton({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    if (!product.isDrink || !product.isAvailable) return const SizedBox.shrink();
    return Tooltip(
      message: 'Prepara tu bebida',
      child: Semantics(
        button: true,
        label: 'Prepara tu bebida ${product.name}',
        child: Breathing(
          scale: 1.08,
          child: PressScale(
            onTap: () => DrinkStudioPage.open(context, product),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [Color(0xFFC08A55), AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 5, offset: const Offset(0, 2))],
              ),
              child: const Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.local_cafe_rounded, size: 17, color: Colors.white),
                  Positioned(top: 4, right: 3, child: Icon(Icons.auto_awesome_rounded, size: 9, color: AppColors.accentYellow)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta invitación del detalle de producto (solo bebidas).
class DrinkStudioCta extends StatelessWidget {
  const DrinkStudioCta({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    if (!product.isDrink || !product.isAvailable) return const SizedBox.shrink();
    return PressScale(
      onTap: () => DrinkStudioPage.open(context, product),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(colors: [Color(0xFFB88A5C), AppColors.primary, Color(0xFF7A4F2C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(color: StudioColors.cream.withValues(alpha: 0.22), shape: BoxShape.circle),
              child: const Icon(Icons.brush_rounded, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Prepara tu bebida', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                  SizedBox(height: 2),
                  Text('Minijuego opcional: elige, vierte, mezcla y dibuja tu latte art.', style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.25)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
