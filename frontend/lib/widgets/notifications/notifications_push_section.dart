import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'notification_channel_tile.dart';

/// Único ajuste de notificaciones: activar/desactivar las push de este
/// dispositivo.
class NotificationsPushSection extends StatelessWidget {
  final bool pushNotifications;
  final ValueChanged<bool> onPushChanged;

  /// Preferencias de comunicación (opcionales: si no se pasan, solo se
  /// muestra el switch de push).
  final bool? promotions;
  final ValueChanged<bool>? onPromotionsChanged;
  final bool? news;
  final ValueChanged<bool>? onNewsChanged;

  const NotificationsPushSection({
    super.key,
    required this.pushNotifications,
    required this.onPushChanged,
    this.promotions,
    this.onPromotionsChanged,
    this.news,
    this.onNewsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final iconBg = isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;
    final card = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Column(
      children: [
        NotificationChannelTile(
          title: 'Notificaciones Push',
          subtitle: 'Recibe alertas en tu dispositivo',
          icon: Icons.smartphone_outlined,
          iconBg: iconBg,
          iconColor: AppColors.primary,
          value: pushNotifications,
          onChanged: onPushChanged,
          cardColor: card,
          textColor: text,
          subtitleColor: sub,
        ),
        if (promotions != null && onPromotionsChanged != null)
          NotificationChannelTile(
            title: 'Promociones y cupones',
            subtitle: 'Descuentos y cupones nuevos',
            icon: Icons.card_giftcard,
            iconBg: iconBg,
            iconColor: AppColors.primary,
            value: promotions!,
            onChanged: onPromotionsChanged!,
            cardColor: card,
            textColor: text,
            subtitleColor: sub,
          ),
        if (news != null && onNewsChanged != null)
          NotificationChannelTile(
            title: 'Novedades',
            subtitle: 'Productos nuevos y eventos',
            icon: Icons.local_cafe_outlined,
            iconBg: iconBg,
            iconColor: AppColors.primary,
            value: news!,
            onChanged: onNewsChanged!,
            cardColor: card,
            textColor: text,
            subtitleColor: sub,
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Los avisos importantes, como el estado de tus pedidos, siempre te llegan.',
            style: TextStyle(color: sub, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
