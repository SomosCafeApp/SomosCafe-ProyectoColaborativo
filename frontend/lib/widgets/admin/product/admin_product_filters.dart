import 'package:flutter/material.dart';

import '../../../core/utils/category_labels.dart';
import '../../../providers/admin_products_provider.dart';
import '../admin_filter_chip_row.dart';

/// Filtros de la lista de productos del admin, en UNA sola fila (igual
/// que en Pedidos): primero la visibilidad en el menú (Todos / Visibles /
/// Ocultos) y, separadas por una línea, las categorías (si hay más de
/// una), con su nombre en español.
class AdminProductFilters extends StatelessWidget {
  final AdminProductsProvider provider;

  const AdminProductFilters({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    // Se ordenan por el nombre que ve el usuario (en español).
    final categories = provider.categoryOptions.entries.toList()
      ..sort((a, b) => categoryLabel(a.value).toLowerCase().compareTo(categoryLabel(b.value).toLowerCase()));

    return AdminFilterChipRow(
      items: [
        for (final filter in ProductVisibilityFilter.values)
          AdminFilterItem(
            label: filter.label,
            count: provider.countFor(filter),
            selected: provider.visibilityFilter == filter,
            onTap: () => provider.setVisibilityFilter(filter),
          ),
        if (categories.length > 1)
          for (var i = 0; i < categories.length; i++)
            AdminFilterItem(
              label: categoryLabel(categories[i].value),
              count: provider.countForCategory(categories[i].key),
              selected: provider.categoryFilter == categories[i].key,
              onTap: () => provider.toggleCategoryFilter(categories[i].key),
              dividerBefore: i == 0,
            ),
      ],
    );
  }
}
