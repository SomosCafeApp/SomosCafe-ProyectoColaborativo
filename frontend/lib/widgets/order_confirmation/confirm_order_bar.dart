import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Barra inferior con el botón "Confirmar pedido · $total".
class ConfirmOrderBar extends StatelessWidget {
  final double total;
  final bool isLoading;
  final bool enabled;
  final VoidCallback onConfirm;

  const ConfirmOrderBar({
    super.key,
    required this.total,
    required this.isLoading,
    required this.enabled,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: isLoading || !enabled ? null : onConfirm,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  'Confirmar pedido · \$${total.toStringAsFixed(0)} COP',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
