import 'package:flutter/material.dart';

class CustomChipGrid extends StatelessWidget {
  final List<Map<String, String?>> options;
  final String? selectedValue;
  final Set<String>? selectedSet;
  final ValueChanged<String> onTap;
  final Color selectedBg;
  final Color primaryColor;
  final Color borderColor;
  final Color textColor;
  final Color mutedColor;

  const CustomChipGrid({
    super.key,
    required this.options,
    this.selectedValue,
    this.selectedSet,
    required this.onTap,
    required this.selectedBg,
    required this.primaryColor,
    required this.borderColor,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: options.map((opt) {
        final title = opt['title']!;
        final price = opt['price'];
        final isSelected = selectedSet != null ? selectedSet!.contains(title) : selectedValue == title;

        return GestureDetector(
          onTap: () => onTap(title),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? selectedBg : Colors.transparent,
              border: Border.all(color: isSelected ? primaryColor : borderColor),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: textColor)),
                if (price != null) Text(price, style: TextStyle(fontSize: 9, color: mutedColor)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}