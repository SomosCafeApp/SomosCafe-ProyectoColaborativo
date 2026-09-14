import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class SavedPaymentMethodsSection extends StatelessWidget {
  final String defaultMethod;
  final ValueChanged<String> onSetDefault;

  const SavedPaymentMethodsSection({
    super.key,
    required this.defaultMethod,
    required this.onSetDefault,
  });

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

    final defaultBadgeBg = isDark
        ? AppColors.darkSurfaceSubtle
        : AppColors.lightSurfaceSubtle;

    final dividerColor = isDark
        ? AppColors.darkSurfaceSubtle
        : AppColors.lightSurfaceSubtle;

    final setDefaultBtnBg = isDark
        ? AppColors.darkSurfaceSubtle
        : AppColors.lightSurfaceSubtle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mis Métodos de Pago',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),

        const SizedBox(height: 12),

        _buildSavedMethodCard(
          title: 'Tarjeta de Crédito',
          subtitle: '**** **** **** 4532',
          icon: Icons.credit_card_rounded,
          iconBg: isDark
              ? AppColors.darkSurfaceSubtle
              : AppColors.lightSurfaceSubtle,
          iconColor: AppColors.primary,
          isDefault: defaultMethod == 'card',
          onSetDefault: () => onSetDefault('card'),
          cardColor: cardColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          defaultBadgeBg: defaultBadgeBg,
          dividerColor: dividerColor,
          setDefaultBtnBg: setDefaultBtnBg,
        ),

        _buildSavedMethodCard(
          title: 'Efectivo',
          subtitle: 'Pago contra entrega',
          icon: Icons.attach_money_rounded,
          iconBg: isDark
              ? AppColors.darkSurfaceSubtle
              : AppColors.lightSurfaceSubtle,
          iconColor: AppColors.primary,
          isDefault: defaultMethod == 'cash',
          onSetDefault: () => onSetDefault('cash'),
          cardColor: cardColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          defaultBadgeBg: defaultBadgeBg,
          dividerColor: dividerColor,
          setDefaultBtnBg: setDefaultBtnBg,
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text(
              'Agregar Tarjeta',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSavedMethodCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required bool isDefault,
    required VoidCallback onSetDefault,
    required Color cardColor,
    required Color textColor,
    required Color subtitleColor,
    required Color defaultBadgeBg,
    required Color dividerColor,
    required Color setDefaultBtnBg,
  }) {
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: textColor,
                            ),
                          ),
                        ),

                        if (isDefault) ...[
                          const SizedBox(width: 8),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: defaultBadgeBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check,
                                  size: 12,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Predeterminado',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (!isDefault) ...[
            const SizedBox(height: 12),

            Divider(
              height: 1,
              color: dividerColor,
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onSetDefault,
                style: TextButton.styleFrom(
                  backgroundColor: setDefaultBtnBg,
                  foregroundColor: textColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Establecer como predeterminado',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}