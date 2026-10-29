import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/voice_service.dart';

/// Barra de escritura del chat con micrófono. Lo dictado se escribe en
/// la caja de texto: el cliente puede corregirlo antes de enviarlo.
class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  /// Estado de la voz y acciones (si [onMic] es null no se muestra el micrófono).
  final VoiceState voiceState;
  final VoidCallback? onMic;
  final VoidCallback? onCancelVoice;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.isSending,
    required this.onSend,
    this.voiceState = VoiceState.idle,
    this.onMic,
    this.onCancelVoice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final inputBg = isDark ? AppColors.darkSurfaceSubtle : AppColors.catWarm;

    final listening = voiceState == VoiceState.listening;
    final processing = voiceState == VoiceState.processing;

    final hint = listening
        ? 'Escuchando… habla ahora'
        : processing
            ? 'Procesando tu voz…'
            : 'Escribe un mensaje...';

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), offset: const Offset(0, -2), blurRadius: 4),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (listening || processing)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    if (processing)
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.primary))
                    else
                      const _PulseDot(),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        listening
                            ? 'Escuchando… toca el micrófono para terminar'
                            : 'Convirtiendo tu voz en texto…',
                        style: TextStyle(color: subtitleColor, fontSize: 13),
                      ),
                    ),
                    if (listening)
                      TextButton(
                        onPressed: onCancelVoice,
                        child: const Text('Cancelar'),
                      ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: TextStyle(color: textColor, fontSize: 15),
                    textInputAction: TextInputAction.send,
                    minLines: 1,
                    maxLines: 4,
                    onSubmitted: (_) => onSend(),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(color: subtitleColor, fontSize: 14),
                      filled: true,
                      fillColor: inputBg,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                if (onMic != null) ...[
                  const SizedBox(width: 6),
                  Semantics(
                    button: true,
                    label: listening ? 'Dejar de grabar' : 'Hablar con el asistente',
                    child: IconButton(
                      onPressed: (isSending || processing) ? null : onMic,
                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                      style: IconButton.styleFrom(
                        backgroundColor: listening ? const Color(0xFFE53935) : inputBg,
                        shape: const CircleBorder(),
                      ),
                      icon: Icon(
                        listening ? Icons.stop_rounded : Icons.mic_none_rounded,
                        color: listening ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 6),
                Semantics(
                  button: true,
                  label: 'Enviar mensaje',
                  child: IconButton(
                    onPressed: (isSending || listening) ? null : onSend,
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.45),
                      shape: const CircleBorder(),
                    ),
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.35, end: 1.0).animate(_c),
      child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle)),
    );
  }
}
