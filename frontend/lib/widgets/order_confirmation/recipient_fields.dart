import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'checkout_field_style.dart';

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
          textInputAction: TextInputAction.next,
          maxLength: 60,
          decoration: checkoutFieldDecoration(
            context,
            label: 'Nombre de quien recibe',
            hint: 'Ej.: María Pérez',
            icon: Icons.person_outline_rounded,
          ),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa el nombre de quien recibe' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          maxLength: 15,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]'))],
          decoration: checkoutFieldDecoration(
            context,
            label: 'Teléfono de contacto',
            hint: 'Ej.: 300 123 4567',
            icon: Icons.phone_outlined,
          ),
          validator: (v) {
            final value = (v ?? '').trim();
            return RegExp(r'^\+?[0-9\s-]{7,15}$').hasMatch(value) ? null : 'Ingresa un teléfono válido';
          },
        ),
      ],
    );
  }
}
