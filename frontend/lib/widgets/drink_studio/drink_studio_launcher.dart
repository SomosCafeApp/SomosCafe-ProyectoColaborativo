import 'package:flutter/material.dart';

import '../../animations/animations.dart';
import '../../core/constants/app_colors.dart';
import '../../pages/drink_studio_page.dart';
import 'studio_colors.dart';

/// Abre DrinkStudio directo (sin pantallas intermedias ni selección de
/// productos): el minijuego es independiente del catálogo.
Future<void> openDrinkStudio(BuildContext context) => DrinkStudioPage.open(context);

/// Ícono de acceso a DrinkStudio. Se muestra en las cinco pantallas
/// principales (Inicio, Menú, Buscar, Carrito y Perfil) siempre en la
/// misma posición, con el mismo diseño y el mismo comportamiento.
class DrinkStudioLauncher extends StatelessWidget {
  const DrinkStudioLauncher({super.key});

  /// Tamaño táctil cómodo (mínimo recomendado: 48).
  static const double size = 48;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'DrinkStudio',
      child: Semantics(
        button: true,
        label: 'Abrir DrinkStudio, el minijuego para preparar un latte',
        child: Breathing(
          scale: 1.05,
          child: PressScale(
            onTap: () => openDrinkStudio(context),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: StudioColors.brand,
                border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 2),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: const Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.local_cafe_rounded, size: 24, color: Colors.white),
                  Positioned(top: 9, right: 9, child: Icon(Icons.auto_awesome_rounded, size: 11, color: AppColors.accentYellow)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
