import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/order.dart';
import '../models/order_payment.dart';
import 'main_navigation_screen.dart';

import '../animations/animations.dart';
class OrderSuccessPage extends StatelessWidget {
  final Order order;

  const OrderSuccessPage({super.key, required this.order});

  String get _orderNumber {
    final id = order.id;
    final shortId = id.length >= 6 ? id.substring(id.length - 6) : id;
    return '#${shortId.toUpperCase()}';
  }

  String get _title =>
      order.isTransfer ? '¡Comprobante enviado!' : '¡Pedido Confirmado!';

  /// Qué sigue según el método de pago elegido.
  String get _message {
    if (order.isTransfer) {
      return 'Estamos validando tu pago. Te avisaremos cuando sea validado y comencemos a preparar tu café.';
    }

    final payTo = order.deliveryType == DeliveryType.delivery
        ? 'Paga en efectivo al domiciliario cuando recibas tu pedido.'
        : 'Paga en efectivo en la cafetería cuando recojas tu pedido.';

    return 'Recibimos tu pedido. $payTo Puedes cancelarlo desde Mis Pedidos durante los próximos 10 minutos y te avisaremos cuando cambie de estado.';
  }

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
      body: Stack(
        children: [
      Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono con contenedor decorativo adaptativo
              AnimatedCheck(
                size: 120,
                color: Colors.green,
                background: iconContainerBg,
              ),
              const SizedBox(height: 28),
              FadeSlideIn(
                delay: const Duration(milliseconds: 500),
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
              Text(
                _title,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Pedido $_orderNumber · \$${order.total.toStringAsFixed(0)} COP',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: primaryBrown,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _message,
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
            ],
          ),
        ),
      ),
      const Positioned.fill(child: IgnorePointer(child: BeanRain())),
        ],
      ),
    );
  }
}