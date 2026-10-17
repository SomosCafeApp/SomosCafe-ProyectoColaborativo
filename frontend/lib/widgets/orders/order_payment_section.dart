import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/order.dart';
import '../payment/payment_proof_viewer.dart';
import '../payment/payment_summary.dart';

/// Pago del pedido dentro de la tarjeta expandida del historial: método,
/// estado y, si el cliente subió un comprobante, el botón para verlo.
class OrderPaymentSection extends StatelessWidget {
  final Order order;

  const OrderPaymentSection({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: PaymentSummaryRow(order: order),
        ),
        if (order.hasProof)
          ViewProofButton(onPressed: () => showPaymentProof(context, order.paymentProofUrl)),
      ],
    );
  }
}

/// Aviso visible SIN expandir la tarjeta cuando el cliente eligió
/// transferencia pero todavía no subió el comprobante.
class PaymentProofBanner extends StatelessWidget {
  final VoidCallback onPay;

  const PaymentProofBanner({super.key, required this.onPay});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Row(
      children: [
        Icon(Icons.upload_file_rounded, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Falta subir tu comprobante de pago',
            style: TextStyle(fontSize: 12, color: subtitleColor),
          ),
        ),
        SizedBox(
          height: 34,
          child: ElevatedButton(
            onPressed: onPay,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
            ),
            child: const Text('Pagar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
