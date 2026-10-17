import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Botón grande "+ Agregar ..." de las secciones del panel admin.
class AdminAddButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const AdminAddButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        onPressed: onPressed,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
