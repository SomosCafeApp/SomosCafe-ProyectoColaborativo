import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/auth_provider.dart';
import '../state/favorites_provider.dart';
import 'addresses_page.dart';
import 'favorites_page.dart';
import 'payment_methods_page.dart';
import 'notifications_page.dart';
import 'orders_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Diálogo genérico para opciones en desarrollo o con información
  void _showFeatureDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Entendido', style: TextStyle(color: Color(0xFFA2784F))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final favoritesCount = context.watch<FavoritesProvider>().favorites.length;

    const primaryBrown = Color(0xFFA2784F);
    const darkBrown = Color(0xFF634832);
    const scaffoldBgColor = Color(0xFFFAF7F2);

    final initial = auth.userName != null && auth.userName!.isNotEmpty
        ? auth.userName![0].toUpperCase()
        : 'JH';

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // --- 1. HEADER PROFILE ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    darkBrown,
                    primaryBrown.withOpacity(0.85),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: darkBrown.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.userName ?? 'Jh',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.email_outlined, color: Colors.white.withOpacity(0.8), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'jh@gmail.com',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.4)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.workspace_premium_outlined, color: Colors.amber, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Nivel Gold',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- 2. LISTA DE OPCIONES CON ACCIONES FUNCIONALES ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildProfileOptionCard(
                    icon: Icons.location_on_outlined,
                    iconBgColor: const Color(0xFFFEF3D6),
                    iconColor: const Color(0xFF8C5C2B),
                    title: 'Direcciones',
                    subtitle: 'Gestiona tus ubicaciones de entrega',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddressesPage()),
                      );
                    },
                  ),
                  _buildProfileOptionCard(
                    icon: Icons.notifications_none_rounded,
                    iconBgColor: const Color(0xFFE1F5FE),
                    iconColor: const Color(0xFF0288D1),
                    title: 'Notificaciones',
                    subtitle: 'Preferencias de alertas',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationsPage()),
                      );
                    },
                  ),
                  _buildProfileOptionCard(
                    icon: Icons.credit_card_rounded,
                    iconBgColor: const Color(0xFFFCE4EC),
                    iconColor: const Color(0xFFC2185B),
                    title: 'Métodos de Pago',
                    subtitle: 'Tarjetas y opciones de pago',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PaymentMethodsPage()),
                      );
                    },
                  ),
                  _buildProfileOptionCard(
                    icon: Icons.favorite_border_rounded,
                    iconBgColor: const Color(0xFFFFF8E1),
                    iconColor: const Color(0xFFE53935),
                    title: 'Favoritos',
                    subtitle: favoritesCount == 0
                        ? '0 productos guardados'
                        : '$favoritesCount producto${favoritesCount == 1 ? '' : 's'} guardado${favoritesCount == 1 ? '' : 's'}',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FavoritesPage()),
                      );
                    },
                  ),
                  _buildProfileOptionCard(
                    icon: Icons.card_giftcard_rounded,
                    iconBgColor: const Color(0xFFFFF8E1),
                    iconColor: const Color(0xFFFFA000),
                    title: 'Recompensas',
                    subtitle: 'Promociones y descuentos',
                    onTap: () => _showFeatureDialog(
                      context,
                      'Puntos de Recompensa',
                      'Tienes 150 puntos acumulados. ¡Sigue comprando para canjear bebidas gratis!',
                    ),
                  ),
                  _buildProfileOptionCard(
                    icon: Icons.history_rounded,
                    iconBgColor: const Color(0xFFE8F5E9),
                    iconColor: const Color(0xFF388E3C),
                    title: 'Historial de Pedidos',
                    subtitle: 'Consulta tus compras anteriores',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OrdersPage()),
                      );
                    },
                  ),
                  _buildProfileOptionCard(
                    icon: Icons.settings_outlined,
                    iconBgColor: const Color(0xFFECEFF1),
                    iconColor: const Color(0xFF546E7A),
                    title: 'Configuración',
                    subtitle: 'Ajustes de la aplicación',
                    onTap: () => _showFeatureDialog(
                      context,
                      'Configuración',
                      'Versión 1.0.0 — Modos de app y preferencias del sistema.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildProfileOptionCard(
                    icon: Icons.logout_rounded,
                    iconBgColor: const Color(0xFFFFEBEE),
                    iconColor: const Color(0xFFD32F2F),
                    title: 'Cerrar Sesión',
                    subtitle: 'Salir de tu cuenta actual',
                    isDestructive: true,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text('Cerrar Sesión'),
                          content: const Text('¿Estás seguro de que deseas salir?'),
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
                    },
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

  Widget _buildProfileOptionCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDestructive ? const Color(0xFFD32F2F) : Colors.black87,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black.withOpacity(0.45),
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: Colors.black.withOpacity(0.3),
            size: 20,
          ),
        ),
      ),
    );
  }
}