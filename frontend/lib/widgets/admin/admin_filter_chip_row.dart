import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'admin_choice_chip.dart';

/// Un chip de filtro: etiqueta, cuántos elementos incluye y su acción.
class AdminFilterItem {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  /// Dibuja una línea vertical antes del chip, para separar grupos de
  /// filtros que comparten la misma fila (p. ej. visibilidad | categorías).
  final bool dividerBefore;

  const AdminFilterItem({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.dividerBefore = false,
  });
}

/// Fila horizontal de chips de filtro con el estilo del panel admin
/// (pedidos y productos comparten este mismo componente). Siempre es UNA
/// sola fila: si no caben, se desplaza (también arrastrando con el mouse
/// en escritorio).
class AdminFilterChipRow extends StatelessWidget {
  final List<AdminFilterItem> items;

  const AdminFilterChipRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dividerColor = isDark ? AppColors.darkBorder : AppColors.lightTextSecondary;

    return SizedBox(
      height: 46,
      child: ScrollConfiguration(
        // Por defecto Flutter no deja arrastrar con el mouse; sin esto,
        // en escritorio los chips que no caben quedarían inalcanzables.
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
            PointerDeviceKind.stylus,
          },
        ),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final item = items[index];

            final chip = AppChoiceChip(
              label: '${item.label} (${item.count})',
              selected: item.selected,
              onSelected: item.onTap,
            );

            if (!item.dividerBefore) return chip;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 1, height: 20, color: dividerColor.withAlpha(90)),
                const SizedBox(width: 8),
                chip,
              ],
            );
          },
        ),
      ),
    );
  }
}
