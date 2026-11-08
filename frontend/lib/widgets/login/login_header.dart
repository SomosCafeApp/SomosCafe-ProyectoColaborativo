import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/tab_navigation.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 260,
          width: double.infinity,
          color: AppColors.primary,
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.local_cafe_outlined,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bienvenido',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Inicia sesión para disfrutar de tu café favorito',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
        Positioned(
          top: 50,
          left: 20,
          child: CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            radius: 18,
            child: IconButton(
        tooltip: 'Volver',
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
              // Vuelve al Inicio reutilizando la navegación principal ya
              // montada (no se crea otra: así se conservan el pop-up de
              // eventos y las alertas de pedidos del admin).
              onPressed: () => TabNavigation.goToTab(context, TabNavigation.homeTab),
            ),
          ),
        ),
      ],
    );
  }
}