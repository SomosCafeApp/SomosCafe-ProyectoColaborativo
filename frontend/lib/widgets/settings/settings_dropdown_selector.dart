import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SettingsDropdownSelector extends StatelessWidget {
  final String value;
  final List items;
  final ValueChanged onChanged;

  const SettingsDropdownSelector({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final scaffoldBgColor = theme.scaffoldBackgroundColor;
    final cardBgColor = theme.cardTheme.color ?? (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    final textColor = theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: scaffoldBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          value: value,
          dropdownColor: cardBgColor,
          isDense: true,
          style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w500),
          items: items
              .map((val) => DropdownMenuItem(value: val, child: Text(val)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}