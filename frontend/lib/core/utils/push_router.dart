import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_event.dart';
import '../../models/product_model.dart';
import '../../pages/admin/admin_orders_page.dart';
import '../../pages/event_detail_page.dart';
import '../../pages/notifications_page.dart';
import '../../pages/orders_page.dart';
import '../../pages/product_detail_page.dart';
import '../../pages/promotion_detail_page.dart';
import '../../pages/rewards_page.dart';
import '../../providers/active_event_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/product_provider.dart';
import '../../services/api_client.dart';
import '../../services/api_exception.dart';

/// Decide a qué pantalla llevar al usuario cuando toca una notificación
/// (push o la lista de la app). Cada tipo abre SU contenido, no una
/// pantalla genérica: producto, promoción, cupón (recompensas), evento
/// o pedido. Si el contenido ya no existe, avisa y muestra la lista.
class PushRouter {
  /// Se asigna al MaterialApp para poder navegar sin un BuildContext.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// [data] es el campo `data` del push (ver backend utils/push.js):
  /// `notificationId`, `type` y `relatedId`.
  static void handle(Map<String, dynamic> data) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) return;

    final notifications = context.read<NotificationProvider>();

    // Refresca la lista y marca como leída la que se tocó.
    final id = data['notificationId']?.toString();
    notifications.fetchNotifications().then((_) {
      if (id != null && id.isNotEmpty) notifications.markAsRead(id);
    });

    openContent(
      type: data['type']?.toString() ?? 'GENERAL',
      relatedId: data['relatedId']?.toString(),
    );
  }

  /// Abre el contenido al que apunta una notificación.
  static Future<void> openContent({
    required String type,
    String? relatedId,
  }) async {
    final context = navigatorKey.currentContext;
    final navigator = navigatorKey.currentState;
    if (context == null || navigator == null) return;

    final auth = context.read<AuthProvider>();
    final hasId = relatedId != null && relatedId.isNotEmpty;

    try {
      switch (type) {
        case 'PRODUCT':
          if (!hasId) break;
          final product = await _loadProduct(context, relatedId);
          navigator.push(MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)));
          return;

        case 'PROMOTION':
          if (!hasId || auth.isAdmin) break;
          final data = await ApiClient.get('/promotions/available/$relatedId', token: auth.token);
          final raw = data['promotion'];
          if (raw is! Map<String, dynamic>) break;
          navigator.push(MaterialPageRoute(
            builder: (_) => PromotionDetailPage(promotion: PromotionInfo.fromJson(raw)),
          ));
          return;

        case 'EVENT':
          if (!hasId) {
            _showEventPopup(context, navigator);
            return;
          }
          final data = await ApiClient.get('/events/$relatedId');
          final raw = data['event'];
          if (raw is! Map<String, dynamic>) break;
          navigator.push(MaterialPageRoute(
            builder: (_) => EventDetailPage(event: AppEvent.fromJson(raw)),
          ));
          return;

        case 'ORDER':
          // Los admins reciben "comprobante por validar"; los clientes,
          // el estado de su pedido.
          navigator.push(MaterialPageRoute(
            builder: (_) => auth.isAdmin ? const AdminOrdersPage() : const OrdersPage(),
          ));
          return;

        case 'REWARD':
          if (!auth.isAdmin) {
            // Cupón nuevo (o reactivado): directo a recompensas.
            navigator.push(MaterialPageRoute(builder: (_) => const RewardsPage()));
            return;
          }
          break;
      }
    } on ApiException catch (e) {
      final gone = e.statusCode == 404;
      _snack(
        context,
        gone
            ? 'Este contenido ya no está disponible.'
            : 'No pudimos abrirlo. Revisa tu conexión e inténtalo de nuevo.',
      );
      if (!gone) return;
    }

    navigator.push(MaterialPageRoute(builder: (_) => const NotificationsPage()));
  }

  static Future<Product> _loadProduct(BuildContext context, String id) async {
    final cached = context.read<ProductProvider>().products.where((p) => p.id == id);
    if (cached.isNotEmpty) return cached.first;

    final data = await ApiClient.get('/products/$id');
    final raw = data['product'];
    if (raw is! Map<String, dynamic>) {
      throw ApiException('Producto no encontrado', statusCode: 404);
    }
    return Product.fromJson(raw);
  }

  static void _showEventPopup(BuildContext context, NavigatorState navigator) {
    navigator.popUntil((route) => route.isFirst);
    context.read<ActiveEventProvider>().requestPopup();
  }

  static void _snack(BuildContext context, String text) {
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }
}
