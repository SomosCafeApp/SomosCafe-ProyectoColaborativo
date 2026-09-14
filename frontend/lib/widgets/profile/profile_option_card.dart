import 'package:flutter/material.dart';

class ProfileOptionCard extends StatelessWidget {
  final Color cardColor;
  final Color textColor;
  final Color subtitleColor;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const ProfileOptionCard({
    super.key,
    required this.cardColor,
    required this.textColor,
    required this.subtitleColor,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDestructive ? Colors.transparent : cardColor,
        borderRadius: BorderRadius.circular(20),
        border: isDestructive
            ? Border.all(color: Colors.redAccent.withAlpha(100), width: 1.2)
            : (isDark ? Border.all(color: Colors.white.withAlpha(10), width: 1) : null),
        boxShadow: (!isDestructive && !isDark)
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          leading: isDestructive
              ? const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22)
              : Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDestructive ? Colors.redAccent : textColor,
            ),
          ),
          subtitle: isDestructive
              ? null
              : Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor,
                  ),
                ),
          trailing: isDestructive
              ? null
              : Icon(
                  Icons.chevron_right_rounded,
                  color: subtitleColor,
                  size: 20,
                ),
        ),
      ),
    );
  }
}