import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/chat_message.dart';

String _cop(double v) => '\$${v.round().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';

/// Confirmación clara de lo que el asistente va a hacer en el carrito.
/// Los importes los calculó el servidor; nada cambia hasta confirmar.
class ChatPendingCard extends StatelessWidget {
  final ChatPendingAction pending;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const ChatPendingCard({super.key, required this.pending, this.onConfirm, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pending.isClearCart ? 'Vaciar el carrito' : 'Confirma tu selección',
            style: TextStyle(color: text, fontSize: 14, fontWeight: FontWeight.w800),
          ),
          if (!pending.isClearCart) ...[
            const SizedBox(height: 8),
            for (final line in pending.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${line.quantity} × ${line.name}', style: TextStyle(color: text, fontSize: 14, fontWeight: FontWeight.w600)),
                          if (line.options.isNotEmpty)
                            Text(line.options.join(' · '), style: TextStyle(color: sub, fontSize: 12)),
                          if (line.promotionName.isNotEmpty)
                            Text(line.promotionName, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Text(_cop(line.lineTotal), style: TextStyle(color: text, fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            const Divider(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: TextStyle(color: text, fontWeight: FontWeight.w800)),
                Text(_cop(pending.total), style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w900)),
              ],
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Se quitarán todos los productos de tu carrito.', style: TextStyle(color: sub, fontSize: 13)),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: onConfirm,
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(0, 44)),
                  child: Text(pending.isClearCart ? 'Sí, vaciar' : 'Agregar al carrito'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
