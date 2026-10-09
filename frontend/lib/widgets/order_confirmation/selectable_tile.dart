import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Opción seleccionable tipo "radio" (dirección o método de pago).
class SelectableTile extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final String title;
  final String subtitle;
  final IconData icon;

  const SelectableTile({
    super.key,
    required this.selected,
    required this.onTap,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : (isDark ? Colors.white24 : Colors.grey.shade300),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Icon(icon, size: 20, color: isDark ? Colors.white70 : Colors.grey.shade700),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey.shade600),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
