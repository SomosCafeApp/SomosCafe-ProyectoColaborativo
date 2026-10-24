import 'dart:convert';

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/chat_message.dart'; // Ajusta a tu modelo de mensaje
import '../support/whatsapp_button.dart';
import 'chat_product_card.dart';
import 'typing_indicator.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Color bubbleOtherColor;
  final Color textColor;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.bubbleOtherColor,
    required this.textColor,
  });

  /// Defensa extra: si por cualquier motivo llega texto con Markdown
  /// o un JSON crudo (por ejemplo, mensajes viejos), se limpia antes
  /// de mostrarlo.
  static String _displayText(String raw) {
    var text = raw.trim();

    if (text.startsWith('{') && text.contains('"message"')) {
      final match = RegExp(r'"message"\s*:\s*"((?:[^"\\]|\\.)*)"').firstMatch(text);
      if (match != null) {
        try {
          text = jsonDecode('"${match.group(1)}"') as String;
        } catch (_) {}
      }
    }

    return text
        .replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (m) => m.group(1) ?? '')
        .replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final maxBubbleWidth = MediaQuery.of(context).size.width * 0.72;

    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: BoxConstraints(maxWidth: maxBubbleWidth),
      decoration: BoxDecoration(
        color: isUser ? AppColors.primary : bubbleOtherColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 18),
        ),
      ),
      child: Text(
        isUser ? message.content : _displayText(message.content),
        style: TextStyle(
          color: isUser ? Colors.white : textColor,
          fontSize: 15,
        ),
      ),
    );

    if (isUser) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [Flexible(child: bubble)],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.coffee_rounded, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                bubble,
                if (message.whatsapp)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: WhatsAppButton(),
                  ),
                // Tarjetas de los productos recomendados: al tocarlas
                // se abre el detalle del producto.
                for (final product in message.products)
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                    child: ChatProductCard(product: product),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TypingIndicatorBubble extends StatelessWidget {
  final Color bubbleColor;

  const TypingIndicatorBubble({super.key, required this.bubbleColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.coffee_rounded, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: const TypingIndicator(),
          ),
        ],
      ),
    );
  }
}