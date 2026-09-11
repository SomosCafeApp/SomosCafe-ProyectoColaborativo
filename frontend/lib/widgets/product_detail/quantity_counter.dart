import 'package:flutter/material.dart';

class QuantityCounter extends StatelessWidget {
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final Color counterBtnBg;
  final Color textColor;

  const QuantityCounter({
    super.key,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    required this.counterBtnBg,
    required this.textColor,
  });

  Widget _buildCounterButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: counterBtnBg,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: textColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildCounterButton(Icons.remove, onDecrement),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            '$value',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
          ),
        ),
        _buildCounterButton(Icons.add, onIncrement),
      ],
    );
  }
}