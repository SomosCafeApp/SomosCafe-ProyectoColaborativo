import 'dart:async';

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

/// Acceso flotante al estudio, como el del ChatBot: el minijuego ya no
/// se impone en la ficha del producto, se abre solo cuando el usuario
/// lo desea. Solo aparece en bebidas compatibles y disponibles; se
/// muestra extendido unos segundos para que se entienda y luego se
/// recoge en un círculo.
class DrinkStudioFab extends StatefulWidget {
  const DrinkStudioFab({super.key, required this.product});
  final Product product;

  /// ¿Esta bebida admite el estudio?
  static bool supports(Product p) => p.isDrink && p.isAvailable;

  @override
  State<DrinkStudioFab> createState() => _DrinkStudioFabState();
}

class _DrinkStudioFabState extends State<DrinkStudioFab> {
  bool _expanded = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _expanded = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!DrinkStudioFab.supports(widget.product)) return const SizedBox.shrink();
    return Semantics(
      button: true,
      label: 'Prepara tu bebida ${widget.product.name}',
      child: Breathing(
        scale: 1.05,
        child: PressScale(
          onTap: () => DrinkStudioPage.open(context, widget.product),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            height: 56,
            padding: EdgeInsets.symmetric(horizontal: _expanded ? 18 : 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: StudioColors.brand,
              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 14, offset: const Offset(0, 6))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Icon(Icons.local_cafe_rounded, size: 26, color: Colors.white),
                    Positioned(top: -6, right: -7, child: Icon(Icons.auto_awesome_rounded, size: 13, color: AppColors.accentYellow)),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  child: _expanded
                      ? const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text('Personaliza', maxLines: 1, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
