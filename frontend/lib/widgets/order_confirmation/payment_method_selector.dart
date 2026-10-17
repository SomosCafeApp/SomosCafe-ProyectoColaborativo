import 'package:flutter/material.dart';

import '../../models/order.dart';
import '../../models/order_payment.dart';
import 'selectable_tile.dart';

/// Elige cómo pagar: efectivo (al domiciliario o en la cafetería, según
/// el tipo de entrega) o transferencia (QR + comprobante).
class PaymentMethodSelector extends StatelessWidget {
  final PaymentMethodType selected;
  final DeliveryType deliveryType;
  final ValueChanged<PaymentMethodType> onChanged;

  const PaymentMethodSelector({
    super.key,
    required this.selected,
    required this.deliveryType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cashSubtitle = deliveryType == DeliveryType.delivery
        ? 'Pagas al domiciliario cuando recibas tu pedido'
        : 'Pagas en la cafetería cuando recojas tu pedido';

    return Column(
      children: [
        SelectableTile(
          selected: selected == PaymentMethodType.cash,
          onTap: () => onChanged(PaymentMethodType.cash),
          title: PaymentMethodType.cash.label,
          subtitle: cashSubtitle,
          icon: Icons.payments_outlined,
        ),
        SelectableTile(
          selected: selected == PaymentMethodType.transfer,
          onTap: () => onChanged(PaymentMethodType.transfer),
          title: PaymentMethodType.transfer.label,
          subtitle: 'Paga con un código QR y sube tu comprobante',
          icon: Icons.qr_code_2_rounded,
        ),
      ],
    );
  }
}
