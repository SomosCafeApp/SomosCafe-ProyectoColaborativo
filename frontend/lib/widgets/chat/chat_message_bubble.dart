import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/chat_message.dart';
import '../../models/product_model.dart';
import '../support/whatsapp_button.dart';
import 'chat_pending_card.dart';
import 'chat_product_card.dart';
import 'typing_indicator.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Color bubbleOtherColor;
  final Color textColor;

  /// Avatar del cliente (el mismo que ve en Perfil y reseñas).
  final Widget? userAvatar;

  /// Es el último mensaje: solo en él se pueden usar atajos y confirmar.
  final bool isLast;
  final bool busy;

  final ValueChanged<String>? onQuickReply;
  final void Function(Product product)? onSelectProduct;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;
  final VoidCallback? onOpenCart;

  /// Lectura en voz alta de la respuesta.
  final VoidCallback? onSpeak;
  final bool isSpeaking;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.bubbleOtherColor,
    required this.textColor,
    this.userAvatar,
    this.isLast = false,
    this.busy = false,
    this.onQuickReply,
    this.onSelectProduct,
    this.onConfirm,
    this.onCancel,
    this.onRetry,
    this.onOpenCart,
    this.onSpeak,
    this.isSpeaking = false,
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
    final shown = isUser ? message.content : _displayText(message.content);

    final textStyle = TextStyle(
      color: isUser ? Colors.white : textColor,
      fontSize: 15,
      height: 1.3,
    );

    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: BoxConstraints(maxWidth: maxBubbleWidth),
      decoration: BoxDecoration(
        color: isUser
            ? AppColors.primary
            : (message.isError ? const Color(0xFFFFEBEE) : bubbleOtherColor),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 18),
        ),
      ),
      child: (!isUser && message.isFresh)
          ? TypewriterText(text: shown, style: textStyle)
          : Text(
              shown,
              style: message.isError ? textStyle.copyWith(color: const Color(0xFFB71C1C)) : textStyle,
            ),
    );

    if (isUser) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(child: bubble),
            if (userAvatar != null) ...[
              const SizedBox(width: 8),
              userAvatar!,
            ],
          ],
        ),
      );
    }

    final showActions = isLast && !busy;

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
                if (onSpeak != null && !message.isError)
                  Semantics(
                    button: true,
                    label: isSpeaking ? 'Detener lectura' : 'Escuchar respuesta',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: onSpeak,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(4, 6, 8, 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSpeaking ? Icons.stop_circle_outlined : Icons.volume_up_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isSpeaking ? 'Detener' : 'Escuchar',
                              style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (message.whatsapp)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: WhatsAppButton(),
                  ),
                // Tarjetas de productos con botones funcionales: elegir /
                // agregar y ver detalles.
                for (final product in message.products)
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ChatProductCard(product: product),
                        if (showActions && onSelectProduct != null)
                          ChatProductActions(
                            product: product,
                            selectLabel: message.products.length > 1 ? 'Elegir' : 'Agregar',
                            onSelect: () => onSelectProduct!(product),
                          ),
                      ],
                    ),
                  ),
                // Propuesta de carrito: nada se agrega hasta confirmar.
                if (message.pending != null && showActions)
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                    child: ChatPendingCard(
                      pending: message.pending!,
                      onConfirm: onConfirm,
                      onCancel: onCancel,
                    ),
                  ),
                if (message.openCart && showActions && onOpenCart != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: FilledButton.icon(
                      onPressed: onOpenCart,
                      icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                      label: const Text('Ir al carrito'),
                      style: FilledButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(0, 44)),
                    ),
                  ),
                if (message.isError && isLast && onRetry != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: OutlinedButton.icon(
                      onPressed: busy ? null : onRetry,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Reintentar'),
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                    ),
                  ),
                if (showActions && message.quickReplies.isNotEmpty && onQuickReply != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        for (final q in message.quickReplies)
                          ActionChip(
                            label: Text(q.label),
                            onPressed: () => onQuickReply!(q.text),
                            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Texto que aparece escribiéndose (respuesta progresiva). Respeta la
/// opción del sistema de reducir animaciones.
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const TypewriterText({super.key, required this.text, required this.style});

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  Timer? _timer;
  int _shown = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.of(context).disableAnimations || widget.text.length > 400) {
        setState(() => _shown = widget.text.length);
        return;
      }
      // ~25 ms por paso, varios caracteres a la vez: rápido, sin bloquear.
      final step = (widget.text.length / 40).ceil().clamp(1, 8);
      _timer = Timer.periodic(const Duration(milliseconds: 25), (t) {
        if (!mounted) return t.cancel();
        setState(() => _shown = (_shown + step).clamp(0, widget.text.length));
        if (_shown >= widget.text.length) t.cancel();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // El lector de pantalla recibe el texto completo desde el inicio.
    return Semantics(
      label: widget.text,
      excludeSemantics: true,
      child: Text(
        // Reserva el alto final para que la burbuja no "salte".
        _shown >= widget.text.length ? widget.text : widget.text.substring(0, _shown),
        style: widget.style,
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