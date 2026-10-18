import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/payment_method_model.dart';

import '../../animations/animations.dart';
/// Solo la lista de métodos guardados; el botón/formulario para
/// agregar uno nuevo vive en la página (mismo patrón que direcciones).
class SavedPaymentMethodsSection extends StatelessWidget {
  final List<PaymentMethod> methods;
  final bool isLoading;
  final ValueChanged<String> onSetDefault;
  final ValueChanged<String> onDelete;

  const SavedPaymentMethodsSection({
    super.key,
    required this.methods,
    required this.isLoading,
    required this.onSetDefault,
    required this.onDelete,
  });

  IconData _iconFor(String type) {
    switch (type) {
      case 'CARD':
        return Icons.credit_card_rounded;
      case 'CASH':
        return Icons.attach_money_rounded;
      case 'BANK_TRANSFER':
        return Icons.account_balance_outlined;
      case 'DIGITAL_WALLET':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.payment_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final defaultBadgeBg = isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;
    final dividerColor = isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;
    final setDefaultBtnBg = isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;
    final iconBg = isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mis Métodos de Pago',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 12),
        if (isLoading && methods.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CoffeeCupLoader()),
          )
        else if (methods.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Aún no tienes métodos de pago guardados.',
              style: TextStyle(fontSize: 13, color: subtitleColor),
            ),
          )
        else
          ...methods.map((method) => _buildSavedMethodCard(
                method: method,
                icon: _iconFor(method.type),
                iconBg: iconBg,
                iconColor: AppColors.primary,
                cardColor: cardColor,
                textColor: textColor,
                subtitleColor: subtitleColor,
                defaultBadgeBg: defaultBadgeBg,
                dividerColor: dividerColor,
                setDefaultBtnBg: setDefaultBtnBg,
              )),
      ],
    );
  }

  Widget _buildSavedMethodCard({
    required PaymentMethod method,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color cardColor,
    required Color textColor,
    required Color subtitleColor,
    required Color defaultBadgeBg,
    required Color dividerColor,
    required Color setDefaultBtnBg,
  }) {
    final isDefault = method.isDefault;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            method.displayTitle,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor),
                          ),
                        ),
                        if (isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: defaultBadgeBg, borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check, size: 12, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text('Predeterminado',
                                    style: TextStyle(
                                        fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(method.displaySubtitle, style: TextStyle(fontSize: 13, color: subtitleColor)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => onDelete(method.id),
                icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFE53935)),
                tooltip: 'Eliminar',
              ),
            ],
          ),
          if (!isDefault) ...[
            const SizedBox(height: 4),
            Divider(height: 1, color: dividerColor),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => onSetDefault(method.id),
                style: TextButton.styleFrom(
                  backgroundColor: setDefaultBtnBg,
                  foregroundColor: textColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(
                  'Establecer como predeterminado',
                  style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
