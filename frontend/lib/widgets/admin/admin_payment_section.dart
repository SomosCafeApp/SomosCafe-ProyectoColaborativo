import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/order.dart';
import '../payment/payment_proof_viewer.dart';
import '../payment/payment_summary.dart';

/// Bloque "Pago" de la tarjeta de pedido del admin: método y estado,
/// el comprobante que subió el cliente y las acciones para validarlo
/// o invalidarlo (comprobante falso → el pedido se cancela).
class AdminPaymentSection extends StatelessWidget {
  final Order order;
  final bool isBusy;
  final VoidCallback onValidate;
  final VoidCallback onInvalidate;

  const AdminPaymentSection({
    super.key,
    required this.order,
    required this.isBusy,
    required this.onValidate,
    required this.onInvalidate,
  });

  static const _green = Color(0xFF4CAF50);
  static const _red = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final showActions = order.awaitsValidation || order.canInvalidateValidated;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pago', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subtitleColor)),
        const SizedBox(height: 6),
        PaymentSummaryRow(order: order),
        if (order.needsProof)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'El cliente todavía no sube el comprobante.',
              style: TextStyle(fontSize: 12, color: subtitleColor),
            ),
          ),
        if (order.hasProof)
          ViewProofButton(onPressed: () => showPaymentProof(context, order.paymentProofUrl)),
        if (showActions) ...[
          const SizedBox(height: 8),
          if (isBusy)
            const Center(child: Padding(padding: EdgeInsets.all(6), child: CircularProgressIndicator()))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (order.awaitsValidation)
                  ElevatedButton.icon(
                    onPressed: onValidate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    icon: const Icon(Icons.verified_rounded, size: 16),
                    label: const Text('Validar pago', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                OutlinedButton.icon(
                  onPressed: onInvalidate,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  icon: const Icon(Icons.block_rounded, size: 16, color: _red),
                  label: const Text('Invalidar pago', style: TextStyle(color: _red, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
        ],
      ],
    );
  }
}
