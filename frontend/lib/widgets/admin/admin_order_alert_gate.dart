import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/push_router.dart';
import '../../models/app_notification.dart';
import '../../providers/admin_orders_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';

/// Avisa en tiempo real al administrador cuando llega un pedido nuevo
/// con la app abierta: sonido del sistema, aviso con acceso directo y
/// actualización silenciosa de la lista de pedidos. (Con la app
/// cerrada o en segundo plano sigue funcionando la push del backend.)
class AdminOrderAlertGate extends StatefulWidget {
  const AdminOrderAlertGate({super.key, required this.child});
  final Widget child;

  @override
  State<AdminOrderAlertGate> createState() => _AdminOrderAlertGateState();
}

class _AdminOrderAlertGateState extends State<AdminOrderAlertGate> {
  late final NotificationProvider _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = context.read<NotificationProvider>();
    _notifications.onFreshNotifications = _onFresh;
  }

  @override
  void dispose() {
    if (_notifications.onFreshNotifications == _onFresh) {
      _notifications.onFreshNotifications = null;
    }
    super.dispose();
  }

  void _onFresh(List<AppNotification> fresh) {
    if (!mounted || !context.read<AuthProvider>().isAdmin) return;

    final orders = fresh.where((n) => n.type == 'ORDER' && n.title == 'Nuevo pedido').toList();
    if (orders.isEmpty) return;

    context.read<AdminOrdersProvider>().fetchOrders(silent: true);
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);

    final text = orders.length == 1 ? orders.first.message : '${orders.length} pedidos nuevos por atender';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 8),
          content: Row(
            children: [
              const Icon(Icons.notifications_active_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(text, maxLines: 3, overflow: TextOverflow.ellipsis)),
            ],
          ),
          action: SnackBarAction(
            label: 'VER',
            textColor: Colors.white,
            onPressed: () => PushRouter.handle({'type': 'ORDER'}),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
