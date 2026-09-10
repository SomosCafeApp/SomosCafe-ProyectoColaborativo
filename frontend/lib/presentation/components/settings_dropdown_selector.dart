import 'package:flutter/material.dart';

class SettingsDropdownSelector<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

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
    final scaffoldBgColor = isDark ? const Color(0xFF1E1410) : const Color(0xFFFAF7F2);
    final cardBgColor = isDark ? const Color(0xFF2D211B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: scaffoldBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          dropdownColor: cardBgColor,
          isDense: true,
          style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w500),
          items: items
              .map((val) => DropdownMenuItem<T>(value: val, child: Text(val.toString())))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}