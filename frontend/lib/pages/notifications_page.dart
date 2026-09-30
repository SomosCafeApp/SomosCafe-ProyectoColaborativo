import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/notification_ui_mapper.dart';
import '../providers/notification_provider.dart';
import '../widgets/profile/profile_sub_page_header.dart'; 
import '../widgets/notifications/notifications_recent_section.dart';
import '../widgets/notifications/notifications_channels_section.dart';
import '../widgets/notifications/notifications_preferences_section.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _soundNotifications = true;

  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 22, minute: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifications = context.read<NotificationProvider>();
      if (notifications.notifications.isEmpty) notifications.fetchNotifications();
    });
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
            subtitle: 'Gestiona tus preferencias de notificación',
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
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else
                      NotificationsRecentSection(
                        recentActivity: recentActivity,
                        onItemTap: (id) => context.read<NotificationProvider>().markAsRead(id),
                        onItemDismissed: (id) => context.read<NotificationProvider>().deleteNotification(id),
                        onMarkAllRead: () => context.read<NotificationProvider>().markAllAsRead(),
                      ),

                    const SizedBox(height: 24),

                  NotificationsChannelsSection(
                    pushNotifications: _pushNotifications,
                    emailNotifications: _emailNotifications,
                    smsNotifications: _smsNotifications,
                    soundNotifications: _soundNotifications,
                    onPushChanged: (value) {
                      setState(() => _pushNotifications = value);
                    },
                    onEmailChanged: (value) {
                      setState(() => _emailNotifications = value);
                    },
                    onSmsChanged: (value) {
                      setState(() => _smsNotifications = value);
                    },
                    onSoundChanged: (value) {
                      setState(() => _soundNotifications = value);
                    },
                  ),

                  const SizedBox(height: 24),

                  NotificationsPreferencesSection(
                    startTime: _startTime,
                    endTime: _endTime,
                    onStartTimeChanged: (time) {
                      setState(() => _startTime = time);
                    },
                    onEndTimeChanged: (time) {
                      setState(() => _endTime = time);
                    },
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