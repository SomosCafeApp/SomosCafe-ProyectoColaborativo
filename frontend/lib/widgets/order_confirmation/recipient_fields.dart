import 'package:flutter/material.dart';

/// Nombre y teléfono de quien recibe el pedido.
class RecipientFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;

  const RecipientFields({super.key, required this.nameController, required this.phoneController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: nameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Nombre', prefixIcon: Icon(Icons.person_outline)),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa el nombre de quien recibe' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Teléfono', prefixIcon: Icon(Icons.phone_outlined)),
          validator: (v) {
            final value = (v ?? '').trim();
            return RegExp(r'^\+?[0-9\s-]{7,15}$').hasMatch(value) ? null : 'Ingresa un teléfono válido';
          },
        ),
      ],
    );
  }
}
