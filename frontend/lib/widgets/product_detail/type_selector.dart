import 'package:flutter/material.dart';

class TypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onChanged;
  final Color selectedBg;
  final Color primaryColor;
  final Color borderColor;
  final Color textColor;

  const TypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
    required this.selectedBg,
    required this.primaryColor,
    required this.borderColor,
    required this.textColor,
  });

  Widget _buildButton(IconData icon, String label) {
    final isSelected = selectedType == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : Colors.transparent,
            border: Border.all(color: isSelected ? primaryColor : borderColor),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? primaryColor : textColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? primaryColor : textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildButton(Icons.thermostat_outlined, 'Caliente'),
        const SizedBox(width: 12),
        _buildButton(Icons.ac_unit_outlined, 'Frío'),
      ],
    );
  }
}