import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Un chip de filtro: etiqueta, cuántos elementos incluye y su acción.
class AdminFilterItem {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const AdminFilterItem({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });
}

/// Fila horizontal de chips de filtro con el estilo del panel admin
/// (pedidos y productos comparten este mismo componente).
class AdminFilterChipRow extends StatelessWidget {
  final List<AdminFilterItem> items;

  const AdminFilterChipRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final unselectedBgColor = isDark ? AppColors.darkSurface : AppColors.lightSurfaceSubtle;
    final unselectedTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = items[index];

          return ChoiceChip(
            label: Text('${item.label} (${item.count})'),
            selected: item.selected,
            selectedColor: AppColors.primary,
            backgroundColor: unselectedBgColor,
            showCheckmark: false,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: item.selected ? FontWeight.bold : FontWeight.w500,
              color: item.selected ? Colors.white : unselectedTextColor,
            ),
            onSelected: (_) => item.onTap(),
          );
        },
      ),
    );
  }
}
