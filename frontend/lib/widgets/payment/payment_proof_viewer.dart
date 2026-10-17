import 'package:flutter/material.dart';

/// Abre el comprobante de pago a pantalla completa (con zoom).
void showPaymentProof(BuildContext context, String url) {
  Navigator.push(
    context,
    MaterialPageRoute(fullscreenDialog: true, builder: (_) => PaymentProofViewer(url: url)),
  );
}

class PaymentProofViewer extends StatelessWidget {
  final String url;

  const PaymentProofViewer({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Comprobante de pago'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: InteractiveViewer(
        minScale: 1,
        maxScale: 5,
        child: Center(
          child: Image.network(
            url,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : const Center(child: CircularProgressIndicator()),
            errorBuilder: (_, __, ___) => const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No se pudo cargar el comprobante',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
