import 'package:flutter/material.dart';

import '../../models/order.dart';
import '../../providers/admin_orders_provider.dart';
import 'admin_filter_chip_row.dart';

/// Chips de filtro de pedidos: Todos, "Por validar" (comprobantes
/// esperando revisión) y uno por cada estado.
class AdminOrderFilterChips extends StatelessWidget {
  final AdminOrdersProvider provider;

  const AdminOrderFilterChips({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return AdminFilterChipRow(
      items: [
        AdminFilterItem(
          label: 'Todos',
          count: provider.countFor(null),
          selected: provider.statusFilter == null && !provider.validationFilter,
          onTap: () => provider.setStatusFilter(null),
        ),
        AdminFilterItem(
          label: 'Por validar',
          count: provider.pendingValidationCount,
          selected: provider.validationFilter,
          onTap: provider.setValidationFilter,
        ),
        for (final status in OrderStatus.values)
          AdminFilterItem(
            label: status.label,
            count: provider.countFor(status),
            selected: provider.statusFilter == status,
            onTap: () => provider.setStatusFilter(status),
          ),
      ],
    );
  }
}
