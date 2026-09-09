import 'package:flutter/material.dart';

class OtherPaymentOptionsSection extends StatelessWidget {
  const OtherPaymentOptionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = textColor.withOpacity(0.6);
    final outlinedBorderColor = isDark ? Colors.white24 : const Color(0xFFE5DDD3);

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
          iconBg: isDark ? const Color(0xFF3A1F2B) : const Color(0xFFFCE4EC),
          iconColor: const Color(0xFFC2185B),
          cardColor: cardColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          outlinedBorderColor: outlinedBorderColor,
        ),
        _buildOtherOptionTile(
          title: 'PSE',
          subtitle: 'Pago desde tu banco',
          icon: Icons.account_balance_outlined,
          iconBg: isDark ? const Color(0xFF17324A) : const Color(0xFFE1F5FE),
          iconColor: const Color(0xFF0288D1),
          cardColor: cardColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          outlinedBorderColor: outlinedBorderColor,
        ),
        _buildOtherOptionTile(
          title: 'Efecty',
          subtitle: 'Pago en puntos Efecty',
          icon: Icons.location_on_outlined,
          iconBg: isDark ? const Color(0xFF3D371C) : const Color(0xFFFFF8E1),
          iconColor: const Color(0xFFF57F17),
          cardColor: cardColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          outlinedBorderColor: outlinedBorderColor,
        ),
        _buildOtherOptionTile(
          title: 'SuChance',
          subtitle: 'Pago en puntos SuChance',
          icon: Icons.location_on_outlined,
          iconBg: isDark ? const Color(0xFF35213D) : const Color(0xFFF3E5F5),
          iconColor: const Color(0xFF7B1FA2),
          cardColor: cardColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          outlinedBorderColor: outlinedBorderColor,
        ),
        _buildOtherOptionTile(
          title: 'Apple Pay',
          subtitle: 'Pago rápido con Apple',
          icon: Icons.phone_iphone_rounded,
          iconBg: isDark ? const Color(0xFF2A3236) : const Color(0xFFECEFF1),
          iconColor: isDark ? Colors.white70 : const Color(0xFF37474F),
          cardColor: cardColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          outlinedBorderColor: outlinedBorderColor,
        ),
        _buildOtherOptionTile(
          title: 'Google Pay',
          subtitle: 'Pago rápido con Google',
          icon: Icons.phone_android_rounded,
          iconBg: isDark ? const Color(0xFF23244A) : const Color(0xFFE8EAF6),
          iconColor: const Color(0xFF3F51B5),
          cardColor: cardColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          outlinedBorderColor: outlinedBorderColor,
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
    required Color outlinedBorderColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            child: Icon(icon, color: iconColor, size: 22),
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
                  style: TextStyle(fontSize: 12, color: subtitleColor),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: outlinedBorderColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            onPressed: () {},
            icon: Icon(Icons.add, size: 14, color: textColor),
            label: Text(
              'Agregar',
              style: TextStyle(
                color: textColor,
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