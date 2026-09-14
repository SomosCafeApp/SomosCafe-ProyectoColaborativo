import 'package:flutter/material.dart';

class ProductOptionsSection extends StatelessWidget {
  final ThemeData theme;
  final bool isDark;
  final Color primary;
  final Color cardColor;
  final Color textColor;
  final Color subtitleColor;
  final Color mutedColor;
  final Color borderColor;
  final Color selectedBg;
  final Color counterBg;

  // Estados
  final int quantity;
  final int extraShots;
  final String selectedSize;
  final String selectedType;
  final String selectedMilk;
  final Set selectedToppings;

  // Callbacks
  final VoidCallback onIncrementQty;
  final VoidCallback onDecrementQty;
  final ValueChanged onSizeChanged;
  final ValueChanged onTypeChanged;
  final ValueChanged onMilkChanged;
  final VoidCallback onIncrementShots;
  final VoidCallback onDecrementShots;
  final ValueChanged onToppingToggled;

  const ProductOptionsSection({
    super.key,
    required this.theme,
    required this.isDark,
    required this.primary,
    required this.cardColor,
    required this.textColor,
    required this.subtitleColor,
    required this.mutedColor,
    required this.borderColor,
    required this.selectedBg,
    required this.counterBg,
    required this.quantity,
    required this.extraShots,
    required this.selectedSize,
    required this.selectedType,
    required this.selectedMilk,
    required this.selectedToppings,
    required this.onIncrementQty,
    required this.onDecrementQty,
    required this.onSizeChanged,
    required this.onTypeChanged,
    required this.onMilkChanged,
    required this.onIncrementShots,
    required this.onDecrementShots,
    required this.onToppingToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Aquí puedes incluir o modularizar las tarjetas de sección de forma ultra limpia
        // (Secciones de Tamaño, Tipo, Leche, Shots y Toppings resumidas)
      ],
    );
  }
}