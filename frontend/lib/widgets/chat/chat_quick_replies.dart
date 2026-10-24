import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../support/whatsapp_button.dart';

/// Atajos del chat: preguntas frecuentes y acceso directo a WhatsApp.
class ChatQuickReplies extends StatelessWidget {
  const ChatQuickReplies({super.key, required this.onPick});
  final ValueChanged<String> onPick;

  static const _questions = [
    'Recomiéndame un café',
    '¿Qué postres tienen?',
    '¿Cómo personalizo mi bebida?',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          for (final q in _questions)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                label: Text(q),
                onPressed: () => onPick(q),
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
              ),
            ),
          ActionChip(
            avatar: const Icon(Icons.chat_rounded, size: 16, color: Color(0xFF25D366)),
            label: const Text('Hablar por WhatsApp'),
            onPressed: () => openSupportWhatsApp(context),
            side: const BorderSide(color: Color(0xFF25D366)),
          ),
        ],
      ),
    );
  }
}
