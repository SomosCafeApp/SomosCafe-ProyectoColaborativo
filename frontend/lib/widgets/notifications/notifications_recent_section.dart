import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/notification_item.dart';
import 'notification_card.dart';
import 'notification_schedule_card.dart';

class NotificationsRecentSection extends StatelessWidget {
  final List<NotificationItem> recentActivity;

  const NotificationsRecentSection({
    super.key,
    required this.recentActivity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final mutedColor = subtitleColor.withValues(alpha: 0.7);

    final unreadDotColor = AppColors.primary;

    final unreadBadgeBg = isDark
        ? AppColors.darkSurfaceSubtle
        : AppColors.lightSurfaceSubtle;

    final unreadBadgeText = AppColors.primary;

    final unreadBorderColor = isDark
        ? AppColors.darkSurfaceSubtle
        : AppColors.lightSurfaceSubtle;

    final infoCardBg = isDark
        ? AppColors.darkSurfaceSubtle
        : AppColors.lightSurfaceSubtle;

    final infoIconBg = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final unreadCount = recentActivity
        .where((notification) => notification.isUnread)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Actividad Reciente',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),

            if (unreadCount > 0) ...[
              const SizedBox(width: 12),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: unreadBadgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount nuevas',
                  style: TextStyle(
                    fontSize: 12,
                    color: unreadBadgeText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 12),

        ...recentActivity.map(
          (item) => NotificationCard(
            item: item,
            unreadDotColor: unreadDotColor,
            cardColor: cardColor,
            textColor: textColor,
            subtitleColor: subtitleColor,
            mutedColor: mutedColor,
            unreadBorderColor: unreadBorderColor,
          ),
        ),

        const SizedBox(height: 12),

        NotificationInfoCard(
          infoCardBg: infoCardBg,
          infoIconBg: infoIconBg,
          textColor: textColor,
          subtitleColor: subtitleColor,
        ),
      ],
    );
  }
}