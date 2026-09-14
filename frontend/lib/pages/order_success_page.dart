import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'main_navigation_screen.dart';

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryBrown = AppColors.primary;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final iconContainerBg = isDark ? const Color(0xFF1E3326) : const Color(0xFFE8F5E9);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono con contenedor decorativo adaptativo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: iconContainerBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 80,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                '¡Pedido Confirmado!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tu café ya se está preparando con los mejores granos. Te notificaremos cuando vaya en camino.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: subtitleColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBrown,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    // Limpia todo el stack de pantallas y reconstruye la navegación desde la raíz
                    Navigator.of(context).pushAndRemoveUntil(
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const MainNavigationScreen(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'Volver al Menú',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}