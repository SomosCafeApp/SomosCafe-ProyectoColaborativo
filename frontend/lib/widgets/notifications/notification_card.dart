import 'package:flutter/material.dart';
import '../../models/notification_item.dart';

class NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final Color unreadDotColor;
  final Color cardColor;
  final Color textColor;
  final Color subtitleColor;
  final Color mutedColor;
  final Color unreadBorderColor;
  final VoidCallback? onTap;
  final VoidCallback? onDismissed;

  const NotificationCard({
    super.key,
    required this.item,
    required this.unreadDotColor,
    required this.cardColor,
    required this.textColor,
    required this.subtitleColor,
    required this.mutedColor,
    required this.unreadBorderColor,
    this.onTap,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final card = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: item.isUnread
            ? Border.all(color: unreadBorderColor, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item.iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: textColor,
                      ),
                    ),
                    if (item.isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: unreadDotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: TextStyle(fontSize: 13, color: subtitleColor),
                ),
                const SizedBox(height: 8),
                Text(
                  item.time,
                  style: TextStyle(fontSize: 11, color: mutedColor),
                ),
              ],
            ),
          ),
        ],
      ),
    ));

    if (onDismissed == null) return card;

    return Dismissible(
      key: ValueKey('notification_${item.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed!(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: const Color(0xFFE53935),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: card,
    );
  }
}