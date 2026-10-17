import 'package:flutter/material.dart';

import '../../../providers/admin_products_provider.dart';
import '../admin_filter_chip_row.dart';

/// Filtros de la lista de productos del admin: visibilidad en el menú
/// (Todos / Visibles / Ocultos) y, si hay más de una, por categoría.
class AdminProductFilters extends StatelessWidget {
  final AdminProductsProvider provider;

  const AdminProductFilters({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final categories = provider.categoryOptions.entries.toList()
      ..sort((a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()));

    return Column(
      children: [
        AdminFilterChipRow(
          items: [
            for (final filter in ProductVisibilityFilter.values)
              AdminFilterItem(
                label: filter.label,
                count: provider.countFor(filter),
                selected: provider.visibilityFilter == filter,
                onTap: () => provider.setVisibilityFilter(filter),
              ),
          ],
        ),
        if (categories.length > 1) ...[
          const SizedBox(height: 8),
          AdminFilterChipRow(
            items: [
              for (final category in categories)
                AdminFilterItem(
                  label: category.value,
                  count: provider.countForCategory(category.key),
                  selected: provider.categoryFilter == category.key,
                  onTap: () => provider.toggleCategoryFilter(category.key),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
