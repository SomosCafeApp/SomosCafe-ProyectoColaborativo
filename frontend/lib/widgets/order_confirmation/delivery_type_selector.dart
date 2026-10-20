import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/order.dart';

/// Selector "En local ($0) / Envío (+$5.000)".
class DeliveryTypeSelector extends StatelessWidget {
  final DeliveryType selected;
  final ValueChanged<DeliveryType> onChanged;

  const DeliveryTypeSelector({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Option(
            type: DeliveryType.pickup,
            title: 'En local',
            subtitle: 'Gratis',
            icon: Icons.storefront_outlined,
            selected: selected == DeliveryType.pickup,
            onTap: () => onChanged(DeliveryType.pickup),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _Option(
            type: DeliveryType.delivery,
            title: 'Envío',
            subtitle: '+\$5.000',
            icon: Icons.delivery_dining_outlined,
            selected: selected == DeliveryType.delivery,
            onTap: () => onChanged(DeliveryType.delivery),
          ),
        ),
      ],
    );
  }
}

class _Option extends StatelessWidget {
  final DeliveryType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _Option({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : (isDark ? Colors.white24 : Colors.grey.shade300),
            width: selected ? 2 : 1,
          ),
          color: selected
              ? (isDark ? const Color(0xFF332B1E).withValues(alpha: 0.5) : const Color(0xFFFDF6E2).withValues(alpha: 0.5))
              : Colors.transparent,
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
