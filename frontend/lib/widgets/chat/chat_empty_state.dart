import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ChatEmptyState extends StatelessWidget {
  final Color textColor;
  final Color subtitleColor;

  const ChatEmptyState({
    super.key,
    required this.textColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              child: Icon(Icons.forum_rounded, size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              '¡Hola! Soy tu Barista Virtual',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 8),
            Text(
              '¿Tienes alguna duda sobre nuestras bebidas o platillos? Escríbeme un mensaje.',
              textAlign: TextAlign.center,
              style: TextStyle(color: subtitleColor, fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}