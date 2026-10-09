import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../pages/addresses_page.dart';
import '../../providers/address_provider.dart';
import 'selectable_tile.dart';

/// Lista de direcciones guardadas para elegir la de entrega, con
/// acceso a AddressesPage para agregar o administrar.
class AddressPickerSection extends StatelessWidget {
  final String? selectedId;
  final ValueChanged<String> onSelected;

  /// Se llama al volver de AddressesPage, ya con la lista recargada.
  final VoidCallback onAfterManage;

  const AddressPickerSection({
    super.key,
    required this.selectedId,
    required this.onSelected,
    required this.onAfterManage,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddressProvider>();
    final textColor = Theme.of(context).colorScheme.onSurface;

    if (provider.isLoading && provider.addresses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (provider.addresses.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('Aún no tienes direcciones guardadas.', style: TextStyle(color: textColor)),
          ),
        for (final address in provider.addresses)
          SelectableTile(
            selected: selectedId == address.id,
            onTap: () => onSelected(address.id),
            title: address.label,
            subtitle: '${address.address}, ${address.details}',
            icon: Icons.location_on_outlined,
          ),
        TextButton.icon(
          onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressesPage()));
            if (!context.mounted) return;
            await context.read<AddressProvider>().fetchAddresses();
            if (context.mounted) onAfterManage();
          },
          icon: const Icon(Icons.add, size: 18),
          label: Text(provider.addresses.isEmpty ? 'Agregar dirección' : 'Administrar direcciones'),
        ),
      ],
    );
  }
}
