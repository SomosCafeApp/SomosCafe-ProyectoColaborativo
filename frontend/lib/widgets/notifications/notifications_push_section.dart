import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'notification_channel_tile.dart';

/// Único ajuste de notificaciones: activar/desactivar las push de este
/// dispositivo.
class NotificationsPushSection extends StatelessWidget {
  final bool pushNotifications;
  final ValueChanged<bool> onPushChanged;

  const NotificationsPushSection({
    super.key,
    required this.pushNotifications,
    required this.onPushChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NotificationChannelTile(
      title: 'Notificaciones Push',
      subtitle: 'Recibe alertas en tu dispositivo',
      icon: Icons.smartphone_outlined,
      iconBg: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
      iconColor: AppColors.primary,
      value: pushNotifications,
      onChanged: onPushChanged,
      cardColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      textColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      subtitleColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
    );
  }
}
