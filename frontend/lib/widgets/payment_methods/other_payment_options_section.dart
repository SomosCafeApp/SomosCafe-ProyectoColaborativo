import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/payment_method_model.dart';

class OtherPaymentOptionsSection extends StatelessWidget {
  final List<PaymentMethod> methods;
  // (provider, type) -> se llama al tocar "Agregar".
  final void Function(String provider, String type) onAdd;

  const OtherPaymentOptionsSection({
    super.key,
    required this.methods,
    required this.onAdd,
  });

  bool _isAdded(String provider) => methods.any((m) => m.provider == provider);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final iconBg = isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;
    final borderColor = isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;

    // (título, subtítulo, ícono, tipo backend)
    const options = [
      ('Nequi', 'Transferencia instantánea', Icons.account_balance_wallet_outlined, 'DIGITAL_WALLET'),
      ('PSE', 'Pago desde tu banco', Icons.account_balance_outlined, 'BANK_TRANSFER'),
      ('Efecty', 'Pago en puntos Efecty', Icons.location_on_outlined, 'BANK_TRANSFER'),
      ('SuChance', 'Pago en puntos SuChance', Icons.location_on_outlined, 'BANK_TRANSFER'),
      ('Apple Pay', 'Pago rápido con Apple', Icons.phone_iphone_rounded, 'DIGITAL_WALLET'),
      ('Google Pay', 'Pago rápido con Google', Icons.phone_android_rounded, 'DIGITAL_WALLET'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Otras Opciones de Pago',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 12),
        ...options.map((option) => _buildOtherOptionTile(
              title: option.$1,
              subtitle: option.$2,
              icon: option.$3,
              type: option.$4,
              isAdded: _isAdded(option.$1),
              iconBg: iconBg,
              iconColor: AppColors.primary,
              cardColor: cardColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
              borderColor: borderColor,
            )),
      ],
    );
  }

  Widget _buildOtherOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String type,
    required bool isAdded,
    required Color iconBg,
    required Color iconColor,
    required Color cardColor,
    required Color textColor,
    required Color subtitleColor,
    required Color borderColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: subtitleColor)),
              ],
            ),
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: isAdded ? Colors.green : textColor,
              side: BorderSide(color: isAdded ? Colors.green : borderColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            onPressed: isAdded ? null : () => onAdd(title, type),
            icon: Icon(isAdded ? Icons.check : Icons.add, size: 14),
            label: Text(
              isAdded ? 'Agregado' : 'Agregar',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
