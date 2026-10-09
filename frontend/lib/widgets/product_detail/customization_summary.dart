import 'package:flutter/material.dart';

import '../../models/product_customization.dart';

/// Resumen corto de una personalización, en hasta dos líneas:
///   Grande · Avena · +2 shots
///   Crema batida · Canela
/// No dibuja nada si el producto va con las opciones por defecto.
class CustomizationSummary extends StatelessWidget {
  final ProductCustomization customization;
  final Color color;
  final double fontSize;

  const CustomizationSummary({
    super.key,
    required this.customization,
    required this.color,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final lines = customization.summaryLines;
    if (lines.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines)
          Text(
            line,
            style: TextStyle(fontSize: fontSize, color: color, height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}
