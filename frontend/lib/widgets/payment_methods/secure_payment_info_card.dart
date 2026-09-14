import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class SecurePaymentInfoCard extends StatelessWidget {
  const SecurePaymentInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final infoCardBg = isDark
        ? AppColors.darkSurfaceSubtle
        : AppColors.lightSurfaceSubtle;

    final infoIconBg = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

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
              color: AppColors.primary,
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