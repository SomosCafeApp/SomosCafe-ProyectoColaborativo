import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../models/order.dart';
import '../models/order_payment.dart';
import '../models/picked_image.dart';
import '../providers/order_provider.dart';
import '../widgets/order_confirmation/confirm_order_bar.dart';
import '../widgets/order_confirmation/confirm_section_title.dart';
import '../widgets/payment/payment_proof_picker.dart';
import '../widgets/payment/payment_qr_card.dart';
import '../widgets/profile/profile_sub_page_header.dart';
import 'order_success_page.dart';

/// Pago por transferencia: muestra el QR de la cafetería (descargable)
/// y recibe la captura del pago, que el administrador valida después.
///
/// Se abre al continuar desde la confirmación del pedido
/// ([fromCheckout] = true) o desde Mis Pedidos cuando el cliente aún no
/// había subido el comprobante.
class TransferPaymentPage extends StatefulWidget {
  final Order order;
  final bool fromCheckout;

  const TransferPaymentPage({
    super.key,
    required this.order,
    this.fromCheckout = false,
  });

  @override
  State<TransferPaymentPage> createState() => _TransferPaymentPageState();
}

class _TransferPaymentPageState extends State<TransferPaymentPage> {
  PickedImage? _proof;

  Future<void> _send() async {
    final proof = _proof;
    if (proof == null) {
      _snack('Primero elige la captura de tu pago');
      return;
    }

    final provider = context.read<OrderProvider>();
    final updated = await provider.uploadPaymentProof(widget.order.id, proof);

    if (!mounted) return;

    if (updated == null) {
      _snack(provider.errorMessage ?? 'No se pudo enviar el comprobante');
      return;
    }

    if (widget.fromCheckout) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OrderSuccessPage(order: updated)),
      );
    } else {
      _snack('Comprobante enviado. Validaremos tu pago pronto.');
      Navigator.pop(context);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final isUploading = context.watch<OrderProvider>().isUploadingProof;
    final order = widget.order;

    return Scaffold(
      // Modo claro: blanco puro (sin el tono crema del resto de la app).
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
      body: Column(
        children: [
          ProfileSubPageHeader(
            title: 'Pagar por transferencia',
            subtitle: 'Pedido #${order.shortId}',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Text(
                    'Total a pagar: \$${order.total.toStringAsFixed(0)} COP',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 24),
                const ConfirmSectionTitle('1. Escanea el código QR'),
                Text(
                  'Descárgalo para cargarlo desde tu app bancaria, o escanéalo desde otro dispositivo.',
                  style: TextStyle(fontSize: 13, color: subtitleColor),
                ),
                const SizedBox(height: 12),
                const PaymentQrCard(),
                const SizedBox(height: 24),
                const ConfirmSectionTitle('2. Sube tu comprobante'),
                Text(
                  order.paymentStatus == PaymentStatus.proofSubmitted
                      ? 'Ya enviaste un comprobante. Puedes reemplazarlo mientras no esté validado.'
                      : 'Cuando termines el pago en tu app, toma una captura de pantalla y súbela aquí.',
                  style: TextStyle(fontSize: 13, color: subtitleColor),
                ),
                const SizedBox(height: 12),
                PaymentProofPicker(
                  picked: _proof,
                  enabled: !isUploading,
                  onPicked: (image) => setState(() => _proof = image),
                ),
                const SizedBox(height: 16),
                Text(
                  'Validaremos tu pago y te avisaremos para comenzar a preparar tu pedido. '
                  'Si sales ahora, podrás subir el comprobante después desde Mis Pedidos.',
                  style: TextStyle(fontSize: 12, color: subtitleColor, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: ConfirmOrderBar(
        label: 'Enviar comprobante',
        isLoading: isUploading,
        enabled: _proof != null,
        onConfirm: _send,
      ),
    );
  }
}
