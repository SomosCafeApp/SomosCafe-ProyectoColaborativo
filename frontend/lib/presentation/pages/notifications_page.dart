import 'package:flutter/material.dart';
import '../../data/models/notification_item.dart';
import '../components/notifications_header.dart';
import '../components/notifications_recent_section.dart';
import '../components/notifications_channels_section.dart';
import '../components/notifications_preferences_section.dart';

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

  final List<NotificationItem> _recentActivity = [
    NotificationItem(
      id: '1',
      title: 'Pedido en Camino',
      subtitle: 'Tu pedido #1234 llegará en 15 minutos',
      time: 'Hace 5 min',
      icon: Icons.inventory_2_outlined,
      iconBgColor: const Color(0xFFF4EFEA),
      iconColor: const Color(0xFF8C6239),
      isUnread: true,
    ),
    NotificationItem(
      id: '2',
      title: '30% de Descuento',
      subtitle: '¡Oferta especial en todos los Frappés!',
      time: 'Hace 1 hora',
      icon: Icons.card_giftcard,
      iconBgColor: const Color(0xFFE8F5E9),
      iconColor: const Color(0xFF2E7D32),
      isUnread: true,
    ),
    NotificationItem(
      id: '3',
      title: 'Nuevo Premio Desbloqueado',
      subtitle: 'Has ganado 100 puntos. ¡Canjéalos ahora!',
      time: 'Hace 2 horas',
      icon: Icons.military_tech_outlined,
      iconBgColor: const Color(0xFFFFF8E1),
      iconColor: const Color(0xFFF57F17),
    ),
    NotificationItem(
      id: '4',
      title: 'Pedido Entregado',
      subtitle: 'Tu pedido #1233 fue entregado exitosamente',
      time: 'Hace 1 día',
      icon: Icons.inventory_2_outlined,
      iconBgColor: const Color(0xFFF4EFEA),
      iconColor: const Color(0xFF8C6239),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          NotificationsHeader(headerColor: theme.colorScheme.primary),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NotificationsRecentSection(recentActivity: _recentActivity),
                  const SizedBox(height: 24),
                  NotificationsChannelsSection(
                    pushNotifications: _pushNotifications,
                    emailNotifications: _emailNotifications,
                    smsNotifications: _smsNotifications,
                    soundNotifications: _soundNotifications,
                    onPushChanged: (val) => setState(() => _pushNotifications = val),
                    onEmailChanged: (val) => setState(() => _emailNotifications = val),
                    onSmsChanged: (val) => setState(() => _smsNotifications = val),
                    onSoundChanged: (val) => setState(() => _soundNotifications = val),
                  ),
                  const SizedBox(height: 24),
                  NotificationsPreferencesSection(
                    startTime: _startTime,
                    endTime: _endTime,
                    onStartTimeChanged: (time) => setState(() => _startTime = time),
                    onEndTimeChanged: (time) => setState(() => _endTime = time),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}