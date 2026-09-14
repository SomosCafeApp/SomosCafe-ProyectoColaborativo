import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class OtherPaymentOptionsSection extends StatelessWidget {
  const OtherPaymentOptionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final iconBg = isDark
        ? AppColors.darkSurfaceSubtle
        : AppColors.lightSurfaceSubtle;

    final borderColor = isDark
        ? AppColors.darkSurfaceSubtle
        : AppColors.lightSurfaceSubtle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Otras Opciones de Pago',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),

        const SizedBox(height: 12),

        _buildOtherOptionTile(
          title: 'Nequi',
          subtitle: 'Transferencia instantánea',
          icon: Icons.account_balance_wallet_outlined,
          iconBg: iconBg,
          iconColor: AppColors.primary,
          cardColor: cardColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          borderColor: borderColor,
        ),

        _buildOtherOptionTile(
          title: 'PSE',
          subtitle: 'Pago desde tu banco',
          icon: Icons.account_balance_outlined,
          iconBg: iconBg,
          iconColor: AppColors.primary,
          cardColor: cardColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          borderColor: borderColor,
        ),

        _buildOtherOptionTile(
          title: 'Efecty',
          subtitle: 'Pago en puntos Efecty',
          icon: Icons.location_on_outlined,
          iconBg: iconBg,
          iconColor: AppColors.primary,
          cardColor: cardColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          borderColor: borderColor,
        ),

        _buildOtherOptionTile(
          title: 'SuChance',
          subtitle: 'Pago en puntos SuChance',
          icon: Icons.location_on_outlined,
          iconBg: iconBg,
          iconColor: AppColors.primary,
          cardColor: cardColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          borderColor: borderColor,
        ),

        _buildOtherOptionTile(
          title: 'Apple Pay',
          subtitle: 'Pago rápido con Apple',
          icon: Icons.phone_iphone_rounded,
          iconBg: iconBg,
          iconColor: AppColors.primary,
          cardColor: cardColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          borderColor: borderColor,
        ),

        _buildOtherOptionTile(
          title: 'Google Pay',
          subtitle: 'Pago rápido con Google',
          icon: Icons.phone_android_rounded,
          iconBg: iconBg,
          iconColor: AppColors.primary,
          cardColor: cardColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          borderColor: borderColor,
        ),
      ],
    );
  }

  Widget _buildOtherOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color cardColor,
    required Color textColor,
    required Color subtitleColor,
    required Color borderColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),

          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: textColor,
              side: BorderSide(
                color: borderColor,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
            ),
            onPressed: () {},
            icon: const Icon(
              Icons.add,
              size: 14,
            ),
            label: const Text(
              'Agregar',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}