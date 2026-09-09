import 'package:flutter/material.dart';

class OptionSelectableBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? extraPrice;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedBg;
  final Color primaryColor;
  final Color borderColor;
  final Color textColor;
  final Color mutedColor;

  const OptionSelectableBox({
    super.key,
    required this.title,
    required this.subtitle,
    this.extraPrice,
    required this.isSelected,
    required this.onTap,
    required this.selectedBg,
    required this.primaryColor,
    required this.borderColor,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : Colors.transparent,
            border: Border.all(color: isSelected ? primaryColor : borderColor),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? primaryColor : textColor)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 10, color: mutedColor)),
              if (extraPrice != null) ...[
                const SizedBox(height: 2),
                Text(extraPrice!, style: TextStyle(fontSize: 9, color: mutedColor)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}