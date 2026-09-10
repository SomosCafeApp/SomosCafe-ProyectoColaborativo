import 'package:flutter/material.dart';
import '../../../data/models/notification_item.dart';
import '../notification_card.dart';
import '../notification_schedule_card.dart';

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
    final cardColor = theme.cardColor;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = textColor.withOpacity(0.6);
    final mutedColor = textColor.withOpacity(0.4);
    final unreadDotColor = theme.colorScheme.primary;
    final unreadBadgeBg = isDark ? const Color(0xFF3D2E26) : const Color(0xFFEFEBE4);
    final unreadBadgeText = isDark ? const Color(0xFFD7B89A) : const Color(0xFF6D4C41);
    final unreadBorderColor = isDark ? const Color(0xFF6D4C41) : const Color(0xFFD7CCC8);
    final infoCardBg = isDark ? const Color(0xFF17324A).withOpacity(0.5) : const Color(0xFFE1F5FE).withOpacity(0.6);
    final infoIconBg = isDark ? const Color(0xFF1E4A6B) : const Color(0xFFBBDEFB);

    final unreadCount = recentActivity.where((n) => n.isUnread).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Actividad Reciente',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
            ),
            if (unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: unreadBadgeBg, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  '$unreadCount nuevas',
                  style: TextStyle(fontSize: 12, color: unreadBadgeText, fontWeight: FontWeight.bold),
                ),
              ),
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