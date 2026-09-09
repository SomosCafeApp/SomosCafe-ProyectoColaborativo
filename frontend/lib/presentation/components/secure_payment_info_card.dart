import 'package:flutter/material.dart';

class SecurePaymentInfoCard extends StatelessWidget {
  const SecurePaymentInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = textColor.withOpacity(0.6);
    final infoCardBg = isDark ? const Color(0xFF0E3A3F).withOpacity(0.5) : const Color(0xFFE0F7FA).withOpacity(0.5);
    final infoIconBg = isDark ? const Color(0xFF13565E) : const Color(0xFFB2EBF2);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: infoCardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: infoIconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.credit_card,
              color: Color(0xFF00838F),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pagos Seguros',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tus datos de pago están protegidos con encriptación de nivel bancario. Nunca almacenamos información sensible.',
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor,
                    height: 1.3,
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