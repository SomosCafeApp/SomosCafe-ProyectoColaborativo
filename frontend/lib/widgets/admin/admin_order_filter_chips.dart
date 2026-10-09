import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/order.dart';
import '../../providers/admin_orders_provider.dart';

class AdminOrderFilterChips extends StatelessWidget {
  final AdminOrdersProvider provider;

  const AdminOrderFilterChips({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<OrderStatus?> filters = [
      null,
      ...OrderStatus.values,
    ];

    final selectedBgColor = AppColors.primary;

    final selectedTextColor = Colors.white;

    final unselectedBgColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurfaceSubtle;

    final unselectedTextColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final OrderStatus? status = filters[index];

          final selected = provider.statusFilter == status;

          final label = status == null ? 'Todos' : status.label;

          return ChoiceChip(
            label: Text(
              '$label (${provider.countFor(status)})',
            ),
            selected: selected,
            selectedColor: selectedBgColor,
            backgroundColor: unselectedBgColor,
            showCheckmark: false,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight:
                  selected ? FontWeight.bold : FontWeight.w500,
              color:
                  selected ? selectedTextColor : unselectedTextColor,
            ),
            onSelected: (_) {
              provider.setStatusFilter(status);
            },
          );
        },
      ),
    );
  }
}