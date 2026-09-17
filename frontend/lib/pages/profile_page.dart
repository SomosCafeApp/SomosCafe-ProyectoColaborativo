import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/profile_option_card.dart';
import '../widgets/profile/logout_button_card.dart';

import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';

import 'addresses_page.dart';
import 'favorites_page.dart';
import 'notifications_page.dart';
import 'orders_page.dart';
import 'payment_methods_page.dart';
import 'rewards_page.dart';
import 'settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = isDark ? const Color(0xFFB0A49E) : const Color(0xFF757575);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: theme.cardTheme.color,
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF381C1C) : const Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFE53935),
                size: 32,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '¿Cerrar Sesión?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '¿Estás seguro de que deseas cerrar tu sesión?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: subtitleColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isDark ? Colors.white24 : Colors.grey.shade300,
                        ),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.read<AuthProvider>().logout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch();
    final FavoritesProvider favProvider = context.watch();
    final int favoritesCount = favProvider.favorites.length;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = theme.cardTheme.color ??
        (isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface);

    final textColor = theme.colorScheme.onSurface;

    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // HEADER
            ProfileHeader(
              userName: auth.userName ?? 'Usuario',
              userLastName: auth.user?.lastName ?? '',
              userEmail: auth.user?.email ?? '',
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // DIRECCIONES
                  ProfileOptionCard(
                    cardColor: cardColor,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    icon: Icons.location_on_outlined,
                    iconBgColor: isDark
                        ? const Color(0xFF33261D)
                        : AppColors.catWarm,
                    iconColor: AppColors.primary,
                    title: 'Direcciones',
                    subtitle: 'Gestiona tus ubicaciones de entrega',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddressesPage(),
                      ),
                    ),
                  ),

                  // NOTIFICACIONES
                  ProfileOptionCard(
                    cardColor: cardColor,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    icon: Icons.notifications_none_rounded,
                    iconBgColor: isDark
                        ? const Color(0xFF1E2B35)
                        : AppColors.catCold,
                    iconColor: const Color(0xFF0288D1),
                    title: 'Notificaciones',
                    subtitle: 'Preferencias de alertas',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsPage(),
                      ),
                    ),
                  ),

                  // MÉTODOS DE PAGO
                  ProfileOptionCard(
                    cardColor: cardColor,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    icon: Icons.credit_card_rounded,
                    iconBgColor: isDark
                        ? const Color(0xFF332029)
                        : AppColors.catSweet,
                    iconColor: const Color(0xFFE91E63),
                    title: 'Métodos de Pago',
                    subtitle: 'Tarjetas y opciones de pago',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaymentMethodsPage(),
                      ),
                    ),
                  ),

                  // FAVORITOS
                  ProfileOptionCard(
                    cardColor: cardColor,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    icon: Icons.favorite_border_rounded,
                    iconBgColor: isDark
                        ? const Color(0xFF332029)
                        : AppColors.catSweet,
                    iconColor: const Color(0xFFE53935),
                    title: 'Favoritos',
                    subtitle: favoritesCount == 0
                        ? '0 productos guardados'
                        : '$favoritesCount '
                            '${favoritesCount == 1 ? "producto" : "productos"} '
                            'guardado${favoritesCount == 1 ? "" : "s"}',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FavoritesPage(),
                      ),
                    ),
                  ),

                  // RECOMPENSAS
                  ProfileOptionCard(
                    cardColor: cardColor,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    icon: Icons.card_giftcard_rounded,
                    iconBgColor: isDark
                        ? const Color(0xFF332B1E)
                        : AppColors.catWarm,
                    iconColor: AppColors.accentYellow,
                    title: 'Recompensas',
                    subtitle: 'Promociones y descuentos',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RewardsPage(),
                      ),
                    ),
                  ),

                  // HISTORIAL DE PEDIDOS
                  ProfileOptionCard(
                    cardColor: cardColor,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    icon: Icons.history_rounded,
                    iconBgColor: isDark
                        ? const Color(0xFF1E3326)
                        : const Color(0xFFE8F5E9),
                    iconColor: const Color(0xFF4CAF50),
                    title: 'Historial de Pedidos',
                    subtitle: 'Consulta tus compras anteriores',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OrdersPage(),
                      ),
                    ),
                  ),

                  // CONFIGURACIÓN
                  ProfileOptionCard(
                    cardColor: cardColor,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    icon: Icons.settings_outlined,
                    iconBgColor: isDark
                        ? AppColors.darkSurfaceSubtle
                        : AppColors.lightSurfaceSubtle,
                    iconColor: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    title: 'Configuración',
                    subtitle: 'Ajustes de la aplicación',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsPage(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // CERRAR SESIÓN (Componente separado y centrado)
                  LogoutButtonCard(
                    onTap: () => _showLogoutDialog(context),
                  ),

                  const SizedBox(height: 16),

                  // VERSIÓN
                  Text(
                    'Versión 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor.withAlpha(180),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}