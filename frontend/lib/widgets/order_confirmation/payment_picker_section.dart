import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../pages/payment_methods_page.dart';
import '../../providers/payment_method_provider.dart';
import 'selectable_tile.dart';

/// Lista de métodos de pago guardados para elegir uno, con acceso a
/// PaymentMethodsPage para agregar o administrar.
class PaymentPickerSection extends StatelessWidget {
  final String? selectedId;
  final ValueChanged<String> onSelected;

  /// Se llama al volver de PaymentMethodsPage, ya con la lista recargada.
  final VoidCallback onAfterManage;

  const PaymentPickerSection({
    super.key,
    required this.selectedId,
    required this.onSelected,
    required this.onAfterManage,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PaymentMethodProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (provider.isLoading && provider.methods.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (provider.methods.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Aún no tienes métodos de pago guardados.',
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ),
        for (final method in provider.methods)
          SelectableTile(
            selected: selectedId == method.id,
            onTap: () => onSelected(method.id),
            title: method.displayTitle,
            subtitle: method.displaySubtitle,
            icon: Icons.credit_card_rounded,
          ),
        TextButton.icon(
          onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsPage()));
            if (!context.mounted) return;
            await context.read<PaymentMethodProvider>().fetchPaymentMethods();
            if (context.mounted) onAfterManage();
          },
          icon: const Icon(Icons.add, size: 18),
          label: Text(provider.methods.isEmpty ? 'Agregar método de pago' : 'Administrar métodos de pago'),
        ),
        Text(
          'El cobro real todavía se hace fuera de la app; el método queda registrado en el pedido.',
          style: TextStyle(
            fontSize: 11,
            fontStyle: FontStyle.italic,
            color: isDark ? Colors.white54 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
