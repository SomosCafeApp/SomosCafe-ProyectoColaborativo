import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/config/payment_config.dart';
import '../../core/constants/app_colors.dart';
import '../../services/payment_qr_service.dart';

/// Tarjeta con el código QR de la cafetería y el botón para
/// descargarlo (guardarlo en la galería).
class PaymentQrCard extends StatefulWidget {
  const PaymentQrCard({super.key});

  @override
  State<PaymentQrCard> createState() => _PaymentQrCardState();
}

class _PaymentQrCardState extends State<PaymentQrCard> {
  bool _isSaving = false;

  Future<void> _download() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSaving = true);

    final message = await PaymentQrService.saveToGallery();

    if (!mounted) return;
    setState(() => _isSaving = false);
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? (isDark ? AppColors.darkSurface : AppColors.lightSurface);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(isDark ? 40 : 8), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // El QR va siempre sobre blanco: en modo oscuro, un QR sobre
          // fondo oscuro no se puede escanear.
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFEEEEEE)),
            ),
            child: Image.asset(
              PaymentConfig.qrAssetPath,
              width: 230,
              height: 230,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const _MissingQr(),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: _isSaving ? null : _download,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary.withAlpha(120)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              ),
              icon: _isSaving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(Icons.download_rounded, size: 18, color: AppColors.primary),
              label: Text(
                'Descargar QR',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Se muestra si todavía no existe el archivo del QR en assets.
class _MissingQr extends StatelessWidget {
  const _MissingQr();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      height: 230,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_2_rounded, size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            'El código QR aún no está disponible.\nComunícate con la cafetería.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          if (kDebugMode)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Dev: agrega ${PaymentConfig.qrAssetPath}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Color(0xFFE53935)),
              ),
            ),
        ],
      ),
    );
  }
}
