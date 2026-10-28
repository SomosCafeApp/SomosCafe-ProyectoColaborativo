import 'package:flutter/material.dart';

import '../../core/utils/money_format.dart';
import '../../models/product_customization.dart';
import 'custom_chip_grid.dart';
import 'custom_section_card.dart';
import 'delivery_info_section.dart';
import 'option_selectable_box.dart';
import 'quantity_counter.dart';
import 'type_selector.dart';

/// Agrupa las secciones de Tamaño, Tipo, Leche, Shots extra,
/// Toppings y Entrega. Se extrajo de ProductDetailPage para
/// mantener ese archivo corto; todo el estado sigue viviendo en
/// la página (se pasa por parámetros y callbacks).
class ProductCustomizationSection extends StatelessWidget {
  final Color cardColor;
  final Color textColor;
  final Color mutedColor;
  final Color selectedBg;
  final Color primary;
  final Color borderColor;
  final Color counterBg;

  /// Precio de lista del producto: define el ajuste real de cada tamaño.
  final double basePrice;

  final String selectedSize;
  final String selectedType;
  final String selectedMilk;
  final int extraShots;
  final Set<String> selectedToppings;

  final ValueChanged<String> onSizeChanged;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onMilkChanged;
  final VoidCallback onIncrementShots;
  final VoidCallback onDecrementShots;
  final ValueChanged<String> onToppingToggle;

  const ProductCustomizationSection({
    super.key,
    required this.cardColor,
    required this.textColor,
    required this.mutedColor,
    required this.selectedBg,
    required this.primary,
    required this.borderColor,
    required this.counterBg,
    required this.basePrice,
    required this.selectedSize,
    required this.selectedType,
    required this.selectedMilk,
    required this.extraShots,
    required this.selectedToppings,
    required this.onSizeChanged,
    required this.onTypeChanged,
    required this.onMilkChanged,
    required this.onIncrementShots,
    required this.onDecrementShots,
    required this.onToppingToggle,
  });

  // Etiquetas y precios salen de las tablas reales (las del servidor
  // cuando ya se descargaron): nada de textos con precio escritos a mano.
  static List<Map<String, String>> get _milkOptions => [
        for (final e in ProductCustomization.milkPrices.entries) {'title': e.key, if (e.value != 0) 'price': formatExtra(e.value)},
      ];

  static const _toppingNames = ['Crema batida', 'Canela', 'Chispas', 'Caramelo'];

  static List<Map<String, String>> get _toppingOptions => [
        for (final t in _toppingNames) {'title': t, 'price': formatExtra(ProductCustomization.toppingPrices[t] ?? 0)},
      ];

  /// Ajuste del tamaño para ESTE producto (con el piso del Pequeño).
  String? _sizePrice(String size) {
    final adj = ProductCustomization.sizeAdjustment(size, basePrice);
    return adj == 0 ? null : formatExtra(adj);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tamaño
        CustomSectionCard(
          cardColor: cardColor,
          textColor: textColor,
          mutedColor: mutedColor,
          title: 'Tamaño',
          child: Row(
            children: [
              _sizeOption('Pequeño', '8oz', '-\$3.000'),
              const SizedBox(width: 8),
              _sizeOption('Mediano', '12oz', _sizePrice('Mediano')),
              const SizedBox(width: 8),
              _sizeOption('Grande', '16oz', '+\$5.000'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Tipo
        CustomSectionCard(
          cardColor: cardColor,
          textColor: textColor,
          mutedColor: mutedColor,
          title: 'Tipo',
          child: TypeSelector(
            selectedType: selectedType,
            onChanged: onTypeChanged,
            selectedBg: selectedBg,
            primaryColor: primary,
            borderColor: borderColor,
            textColor: textColor,
          ),
        ),
        const SizedBox(height: 16),

        // Leche
        CustomSectionCard(
          cardColor: cardColor,
          textColor: textColor,
          mutedColor: mutedColor,
          title: 'Tipo de Leche',
          subtitle: 'Opcional',
          child: CustomChipGrid(
            options: _milkOptions,
            selectedValue: selectedMilk,
            onTap: onMilkChanged,
            selectedBg: selectedBg,
            primaryColor: primary,
            borderColor: borderColor,
            textColor: textColor,
            mutedColor: mutedColor,
          ),
        ),
        const SizedBox(height: 16),

        // Shots extra
        CustomSectionCard(
          cardColor: cardColor,
          textColor: textColor,
          mutedColor: mutedColor,
          title: 'Shots Extra',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shots de espresso',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              QuantityCounter(
                value: extraShots,
                counterBtnBg: counterBg,
                textColor: textColor,
                onIncrement: onIncrementShots,
                onDecrement: onDecrementShots,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Toppings
        CustomSectionCard(
          cardColor: cardColor,
          textColor: textColor,
          mutedColor: mutedColor,
          title: 'Toppings',
          child: CustomChipGrid(
            options: _toppingOptions,
            selectedSet: selectedToppings,
            onTap: onToppingToggle,
            selectedBg: selectedBg,
            primaryColor: primary,
            borderColor: borderColor,
            textColor: textColor,
            mutedColor: mutedColor,
          ),
        ),
        const SizedBox(height: 16),

        // Entrega
        CustomSectionCard(
          cardColor: cardColor,
          textColor: textColor,
          mutedColor: mutedColor,
          title: 'Entrega',
          child: DeliveryInfoSection(
            iconBg: selectedBg,
            iconColor: primary,
            textColor: textColor,
            mutedColor: mutedColor,
            borderColor: borderColor,
          ),
        ),
      ],
    );
  }

  Widget _sizeOption(String title, String subtitle, String? price) {
    return OptionSelectableBox(
      title: title,
      subtitle: subtitle,
      extraPrice: price,
      isSelected: selectedSize == title,
      onTap: () => onSizeChanged(title),
      selectedBg: selectedBg,
      primaryColor: primary,
      borderColor: borderColor,
      textColor: textColor,
      mutedColor: mutedColor,
    );
  }
}
