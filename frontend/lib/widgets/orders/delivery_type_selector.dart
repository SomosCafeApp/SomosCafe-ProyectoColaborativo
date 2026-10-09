import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order.dart';

class DeliveryTypeSelector extends StatelessWidget {
  final DeliveryType selectedType;
  final ValueChanged onSelect;

  const DeliveryTypeSelector({
    super.key,
    required this.selectedType,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DeliveryOptionCard(
            type: DeliveryType.pickup,
            selectedType: selectedType,
            title: 'En local',
            subtitle: 'Gratis',
            icon: Icons.storefront_outlined,
            onSelect: onSelect,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DeliveryOptionCard(
            type: DeliveryType.delivery,
            selectedType: selectedType,
            title: 'Envío',
            subtitle: '+\$5.000',
            icon: Icons.delivery_dining_outlined,
            onSelect: onSelect,
          ),
        ),
      ],
    );
  }
}

class _DeliveryOptionCard extends StatelessWidget {
  final DeliveryType type;
  final DeliveryType selectedType;
  final String title;
  final String subtitle;
  final IconData icon;
  final ValueChanged onSelect;

  const _DeliveryOptionCard({
    required this.type,
    required this.selectedType,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selected = selectedType == type;

    return InkWell(
      onTap: () => onSelect(type),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : (isDark ? Colors.white24 : Colors.grey.shade300),
            width: selected ? 2 : 1,
          ),
          color: selected
              ? (isDark
                  ? const Color(0xFF332B1E).withOpacity(0.5)
                  : const Color(0xFFFDF6E2).withOpacity(0.5))
              : Colors.transparent,
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}