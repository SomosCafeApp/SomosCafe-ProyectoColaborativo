import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../pages/admin/admin_orders_page.dart';
import '../../pages/notifications_page.dart';
import '../../pages/orders_page.dart';
import '../../pages/rewards_page.dart';
import '../../providers/active_event_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';

/// Decide a qué pantalla llevar al usuario cuando toca una push.
class PushRouter {
  /// Se asigna al MaterialApp para poder navegar sin un BuildContext.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// [data] es el campo `data` del push (ver backend utils/push.js):
  /// `notificationId`, `type` y `relatedId`.
  static void handle(Map<String, dynamic> data) {
    final context = navigatorKey.currentContext;
    final navigator = navigatorKey.currentState;
    if (context == null || navigator == null) return;

    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) return;

    final notifications = context.read<NotificationProvider>();

    // Refresca la lista y marca como leída la que se tocó.
    final id = data['notificationId']?.toString();
    notifications.fetchNotifications().then((_) {
      if (id != null && id.isNotEmpty) notifications.markAsRead(id);
    });

    // Evento nuevo: volver a la pantalla inicial y mostrar su pop-up.
    if (data['type'] == 'EVENT') {
      navigator.popUntil((route) => route.isFirst);
      context.read<ActiveEventProvider>().requestPopup();
      return;
    }

    final Widget page;
    if (data['type'] == 'ORDER') {
      // Los admins reciben "comprobante por validar"; los clientes,
      // el estado de su pedido.
      page = auth.isAdmin ? const AdminOrdersPage() : const OrdersPage();
    } else if (data['type'] == 'REWARD' && !auth.isAdmin) {
      // Cupón nuevo (o reactivado): directo a recompensas.
      page = const RewardsPage();
    } else {
      page = const NotificationsPage();
    }

    navigator.push(MaterialPageRoute(builder: (_) => page));
  }
}
