import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/notification_ui_mapper.dart';
import '../core/utils/push_router.dart';
import '../providers/notification_provider.dart';
import '../services/push_service.dart';
import '../widgets/profile/profile_sub_page_header.dart';
import '../widgets/notifications/notifications_recent_section.dart';
import '../widgets/notifications/notifications_push_section.dart';

import '../animations/animations.dart';
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifications = context.read<NotificationProvider>();
      if (notifications.notifications.isEmpty) notifications.fetchNotifications();
    });
  }

  Future<void> _onPushChanged(bool value) async {
    final messenger = ScaffoldMessenger.of(context);
    final status = await context.read<NotificationProvider>().setPushEnabled(value);

    if (!mounted || !value || status == PushStatus.registered) return;

    final message = switch (status) {
      PushStatus.permissionDenied =>
        'Activa los permisos de notificaciones de esta app en los ajustes del teléfono.',
      PushStatus.firebaseUnavailable =>
        'Las notificaciones push aún no están disponibles en este dispositivo.',
      _ => 'No se pudo activar. Revisa tu conexión e inténtalo de nuevo.',
    };

    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onPreference({bool? promotions, bool? news}) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await context.read<NotificationProvider>().setPreference(promotions: promotions, news: news);
    if (!mounted || ok) return;
    messenger.showSnackBar(const SnackBar(content: Text('No se pudo guardar. Revisa tu conexión e inténtalo de nuevo.')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notificationProvider = context.watch<NotificationProvider>();
    final recentActivity = notificationProvider.notifications.map(NotificationUiMapper.toItem).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          ProfileSubPageHeader(
            title: 'Notificaciones',
            subtitle: 'Revisa o configura las notificaciones',
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: notificationProvider.fetchNotifications,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (notificationProvider.isLoading && recentActivity.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: CoffeeCupLoader()),
                      )
                    else
                      NotificationsRecentSection(
                        recentActivity: recentActivity,
                        onItemTap: (id) {
                          context.read<NotificationProvider>().markAsRead(id);
                          final tapped = recentActivity.where((n) => n.id == id);
                          if (tapped.isNotEmpty) {
                            PushRouter.openContent(type: tapped.first.type, relatedId: tapped.first.relatedId);
                          }
                        },
                        onItemDismissed: (id) => context.read<NotificationProvider>().deleteNotification(id),
                        onMarkAllRead: () => context.read<NotificationProvider>().markAllAsRead(),
                      ),

                    const SizedBox(height: 24),

                    NotificationsPushSection(
                      pushNotifications: notificationProvider.pushActive,
                      onPushChanged: _onPushChanged,
                      promotions: notificationProvider.promotionsPref,
                      onPromotionsChanged: (v) => _onPreference(promotions: v),
                      news: notificationProvider.newsPref,
                      onNewsChanged: (v) => _onPreference(news: v),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
