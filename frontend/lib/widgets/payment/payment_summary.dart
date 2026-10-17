import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/order.dart';
import '../../models/order_payment.dart';

/// Línea "método de pago + estado" que se usa en el historial de
/// pedidos del cliente y en el panel del administrador.
class PaymentSummaryRow extends StatelessWidget {
  final Order order;

  const PaymentSummaryRow({super.key, required this.order});

  Color get _statusColor {
    if (!order.isTransfer) {
      return order.status == OrderStatus.delivered ? const Color(0xFF4CAF50) : AppColors.primary;
    }
    switch (order.paymentStatus) {
      case PaymentStatus.validated:
        return const Color(0xFF4CAF50);
      case PaymentStatus.invalidated:
        return const Color(0xFFE53935);
      case PaymentStatus.proofSubmitted:
        return const Color(0xFFFF9800);
      case PaymentStatus.awaitingProof:
      case PaymentStatus.pending:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final color = _statusColor;

    return Row(
      children: [
        Icon(order.isTransfer ? Icons.qr_code_2_rounded : Icons.payments_outlined, size: 15, color: subtitleColor),
        const SizedBox(width: 6),
        Text(
          order.paymentMethod.label,
          style: TextStyle(fontSize: 12.5, color: theme.colorScheme.onSurface),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withAlpha(isDark ? 40 : 25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              order.paymentStatusLabel,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ),
      ],
    );
  }
}

/// Botón discreto "Ver comprobante de pago".
class ViewProofButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ViewProofButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          minimumSize: const Size(0, 32),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: Icon(Icons.receipt_long_outlined, size: 16, color: AppColors.primary),
        label: Text(
          'Ver comprobante de pago',
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
      ),
    );
  }
}
