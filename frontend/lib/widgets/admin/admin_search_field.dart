import 'package:flutter/material.dart';

/// Campo de búsqueda simple para las listas del panel admin.
class AdminSearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const AdminSearchField({super.key, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextField(
          onChanged: onChanged,
          decoration: InputDecoration(hintText: hint, prefixIcon: const Icon(Icons.search)),
        ),
      );
}
