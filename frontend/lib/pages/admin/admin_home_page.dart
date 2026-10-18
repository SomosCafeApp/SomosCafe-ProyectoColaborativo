import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/profile/profile_option_card.dart';
import '../../widgets/profile/profile_sub_page_header.dart';
import 'admin_coupons_page.dart';
import 'admin_events_page.dart';
import 'admin_orders_page.dart';
import 'admin_products_page.dart';
import 'admin_promotions_page.dart';

/// Punto de entrada del modo admin (solo visible para cuentas con
/// role == 'ADMIN', ver ProfilePage): Pedidos, Productos, Promociones,
/// Cupones y Eventos.
class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final sections = [
      (
        icon: Icons.receipt_long_rounded,
        iconBg: isDark ? const Color(0xFF1E3326) : const Color(0xFFE8F5E9),
        iconColor: const Color(0xFF4CAF50),
        title: 'Pedidos',
        subtitle: 'Revisa pedidos, cambia su estado y marca entregas',
      ),
      (
        icon: Icons.local_cafe_rounded,
        iconBg: isDark ? const Color(0xFF332B1E) : AppColors.catWarm,
        iconColor: AppColors.accentYellow,
        title: 'Productos',
        subtitle: 'Crea, edita y elimina productos del menú',
      ),
      (
        icon: Icons.percent_rounded,
        iconBg: isDark ? const Color(0xFF1E2A33) : const Color(0xFFE3F2FD),
        iconColor: const Color(0xFF2196F3),
        title: 'Promociones',
        subtitle: 'Descuentos por producto y promo del día',
      ),
      (
        icon: Icons.card_giftcard_rounded,
        iconBg: isDark ? const Color(0xFF33241E) : const Color(0xFFFFF3E0),
        iconColor: const Color(0xFFFF9800),
        title: 'Cupones',
        subtitle: 'Cupones que los clientes canjean con puntos',
      ),
      (
        icon: Icons.event_rounded,
        iconBg: isDark ? const Color(0xFF2A2140) : const Color(0xFFEDE7F6),
        iconColor: const Color(0xFF673AB7),
        title: 'Eventos',
        subtitle: 'Publica eventos de la cafetería',
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          const ProfileSubPageHeader(
            title: 'Panel de Administrador',
            subtitle: 'Gestiona pedidos, productos y más',
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];
                return ProfileOptionCard(
                  cardColor: cardColor,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  icon: section.icon,
                  iconBgColor: section.iconBg,
                  iconColor: section.iconColor,
                  title: section.title,
                  subtitle: section.subtitle,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) {
                        switch (section.title) {
                          case 'Promociones':
                            return const AdminPromotionsPage();
                          case 'Cupones':
                            return const AdminCouponsPage();
                          case 'Productos':
                            return const AdminProductsPage();
                          case 'Eventos':
                            return const AdminEventsPage();
                          default: // 'Pedidos'
                            return const AdminOrdersPage();
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
