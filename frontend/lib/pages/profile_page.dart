import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/profile/profile_header.dart';
import '../widgets/profile/profile_option_card.dart';
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

  void _showLogoutDialog(BuildContext context, Color cardColor, Color textColor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: cardColor,
        title: Text('Cerrar Sesión', style: TextStyle(color: textColor)),
        content: Text('¿Estás seguro de que deseas salir?', style: TextStyle(color: textColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
            },
            child: const Text('Salir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final favoritesCount = context.watch<FavoritesProvider>().favorites.length;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = textColor.withAlpha(150);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            ProfileHeader(
              userName: auth.userName ?? 'Jh',
              userEmail: 'jh@gmail.com',
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  ProfileOptionCard(cardColor: cardColor, textColor: textColor, subtitleColor: subtitleColor, icon: Icons.location_on_outlined, iconBgColor: isDark ? const Color(0xFF3D2E26) : const Color(0xFFFEF3D6), iconColor: const Color(0xFF8C5C2B), title: 'Direcciones', subtitle: 'Gestiona tus ubicaciones de entrega', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressesPage()))),
                  ProfileOptionCard(cardColor: cardColor, textColor: textColor, subtitleColor: subtitleColor, icon: Icons.notifications_none_rounded, iconBgColor: isDark ? const Color(0xFF1B3A4B) : const Color(0xFFE1F5FE), iconColor: const Color(0xFF0288D1), title: 'Notificaciones', subtitle: 'Preferencias de alertas', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage()))),
                  ProfileOptionCard(cardColor: cardColor, textColor: textColor, subtitleColor: subtitleColor, icon: Icons.credit_card_rounded, iconBgColor: isDark ? const Color(0xFF3A1F2B) : const Color(0xFFFCE4EC), iconColor: const Color(0xFFC2185B), title: 'Métodos de Pago', subtitle: 'Tarjetas y opciones de pago', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsPage()))),
                  ProfileOptionCard(cardColor: cardColor, textColor: textColor, subtitleColor: subtitleColor, icon: Icons.favorite_border_rounded, iconBgColor: isDark ? const Color(0xFF3D371C) : const Color(0xFFFFF8E1), iconColor: const Color(0xFFE53935), title: 'Favoritos', subtitle: favoritesCount == 0 ? '0 productos guardados' : '$favoritesCount producto${favoritesCount == 1 ? '' : 's'} guardado${favoritesCount == 1 ? '' : 's'}', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesPage()))),
                  ProfileOptionCard(cardColor: cardColor, textColor: textColor, subtitleColor: subtitleColor, icon: Icons.card_giftcard_rounded, iconBgColor: isDark ? const Color(0xFF3D371C) : const Color(0xFFFFF8E1), iconColor: const Color(0xFFFFA000), title: 'Recompensas', subtitle: 'Promociones y descuentos', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RewardsPage()))),
                  ProfileOptionCard(cardColor: cardColor, textColor: textColor, subtitleColor: subtitleColor, icon: Icons.history_rounded, iconBgColor: isDark ? const Color(0xFF1E3A22) : const Color(0xFFE8F5E9), iconColor: const Color(0xFF388E3C), title: 'Historial de Pedidos', subtitle: 'Consulta tus compras anteriores', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersPage()))),
                  ProfileOptionCard(cardColor: cardColor, textColor: textColor, subtitleColor: subtitleColor, icon: Icons.settings_outlined, iconBgColor: isDark ? const Color(0xFF2A3236) : const Color(0xFFECEFF1), iconColor: const Color(0xFF546E7A), title: 'Configuración', subtitle: 'Ajustes de la aplicación', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()))),
                  const SizedBox(height: 12),
                  ProfileOptionCard(cardColor: cardColor, textColor: textColor, subtitleColor: subtitleColor, icon: Icons.logout_rounded, iconBgColor: isDark ? const Color(0xFF3D1F1F) : const Color(0xFFFFEBEE), iconColor: const Color(0xFFD32F2F), title: 'Cerrar Sesión', subtitle: 'Salir de tu cuenta actual', isDestructive: true, onTap: () => _showLogoutDialog(context, cardColor, textColor)),
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