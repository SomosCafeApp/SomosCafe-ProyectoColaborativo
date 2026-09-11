import 'package:flutter/material.dart';
import '../notification_channel_tile.dart';

class NotificationsChannelsSection extends StatelessWidget {
  final bool pushNotifications;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool soundNotifications;
  final ValueChanged<bool> onPushChanged;
  final ValueChanged<bool> onEmailChanged;
  final ValueChanged<bool> onSmsChanged;
  final ValueChanged<bool> onSoundChanged;

  const NotificationsChannelsSection({
    super.key,
    required this.pushNotifications,
    required this.emailNotifications,
    required this.smsNotifications,
    required this.soundNotifications,
    required this.onPushChanged,
    required this.onEmailChanged,
    required this.onSmsChanged,
    required this.onSoundChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = textColor.withOpacity(0.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Canales de Notificación',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 12),
        NotificationChannelTile(
          title: 'Notificaciones Push',
          subtitle: 'Recibe alertas en tu dispositivo',
          icon: Icons.smartphone_outlined,
          iconBg: isDark ? const Color(0xFF3D2E26) : const Color(0xFFF5F2EC),
          iconColor: const Color(0xFF8C6239),
          value: pushNotifications,
          onChanged: onPushChanged,
          cardColor: cardColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
        ),
        NotificationChannelTile(
          title: 'Correo Electrónico',
          subtitle: 'Recibe ofertas y actualizaciones por email',
          icon: Icons.email_outlined,
          iconBg: isDark ? const Color(0xFF17324A) : const Color(0xFFE1F5FE),
          iconColor: const Color(0xFF0288D1),
          value: emailNotifications,
          onChanged: onEmailChanged,
          cardColor: cardColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
        ),
        NotificationChannelTile(
          title: 'SMS',
          subtitle: 'Recibe confirmaciones por mensaje de texto',
          icon: Icons.chat_bubble_outline_rounded,
          iconBg: isDark ? const Color(0xFF3A1F1F) : const Color(0xFFFFEBEE),
          iconColor: const Color(0xFFE53935),
          value: smsNotifications,
          onChanged: onSmsChanged,
          cardColor: cardColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
        ),
        NotificationChannelTile(
          title: 'Sonidos',
          subtitle: 'Reproducir sonidos para notificaciones',
          icon: Icons.volume_up_outlined,
          iconBg: isDark ? const Color(0xFF3D371C) : const Color(0xFFFFF8E1),
          iconColor: const Color(0xFFFFA000),
          value: soundNotifications,
          onChanged: onSoundChanged,
          cardColor: cardColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
        ),
      ],
    );
  }
}