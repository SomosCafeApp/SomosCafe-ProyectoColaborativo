import 'package:flutter/material.dart';

import '../../models/app_notification.dart';
import '../../models/notification_item.dart';

/// Convierte una [AppNotification] real (del backend) al modelo
/// [NotificationItem] que ya usan las tarjetas de la UI, asignando
/// ícono/colores según el `type` y un texto de tiempo relativo.
class NotificationUiMapper {
  static NotificationItem toItem(AppNotification notification) {
    final style = _styleFor(notification.type);

    return NotificationItem(
      id: notification.id,
      title: notification.title,
      subtitle: notification.message,
      time: _relativeTime(notification.createdAt),
      icon: style.icon,
      iconBgColor: style.bgColor,
      iconColor: style.color,
      isUnread: !notification.isRead,
    );
  }

  static _NotificationStyle _styleFor(String type) {
    switch (type) {
      case 'ORDER':
        return _NotificationStyle(
          icon: Icons.inventory_2_outlined,
          bgColor: const Color(0xFFF4EFEA),
          color: const Color(0xFF8C6239),
        );
      case 'PROMOTION':
        return _NotificationStyle(
          icon: Icons.card_giftcard,
          bgColor: const Color(0xFFE8F5E9),
          color: const Color(0xFF2E7D32),
        );
      case 'REWARD':
        return _NotificationStyle(
          icon: Icons.military_tech_outlined,
          bgColor: const Color(0xFFFFF8E1),
          color: const Color(0xFFF57F17),
        );
      case 'EVENT':
        return _NotificationStyle(
          icon: Icons.event_outlined,
          bgColor: const Color(0xFFE3F2FD),
          color: const Color(0xFF1565C0),
        );
      case 'SYSTEM':
        return _NotificationStyle(
          icon: Icons.settings_outlined,
          bgColor: const Color(0xFFECEFF1),
          color: const Color(0xFF546E7A),
        );
      default: // GENERAL
        return _NotificationStyle(
          icon: Icons.notifications_outlined,
          bgColor: const Color(0xFFF4EFEA),
          color: const Color(0xFF8C6239),
        );
    }
  }

  static String _relativeTime(DateTime? date) {
    if (date == null) return '';

    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 1) return 'Justo ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} día${diff.inDays == 1 ? '' : 's'}';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _NotificationStyle {
  final IconData icon;
  final Color bgColor;
  final Color color;

  _NotificationStyle({required this.icon, required this.bgColor, required this.color});
}
