import 'package:flutter/material.dart';

import '../../core/utils/money_format.dart';
import '../../models/drink_studio_stage.dart';
import '../../providers/drink_studio_provider.dart';
import '../common/styled_confirm_dialog.dart';
import 'studio_colors.dart';

/// Editar / Reiniciar / Guardar receta / Agregar al carrito.
class SummaryActions extends StatelessWidget {
  const SummaryActions({super.key, required this.studio, required this.onAdd, required this.onSave});
  final DrinkStudioProvider studio;
  final VoidCallback onAdd;
  final VoidCallback onSave;

  Future<void> _edit(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(padding: EdgeInsets.only(bottom: 8), child: Text('¿Qué quieres cambiar?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
            for (final step in studio.steps.where((x) => x != StudioStep.result))
              ListTile(
                leading: Icon(step.icon, color: StudioColors.primary),
                title: Text(step.label),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(sheet);
                  studio.goToStep(step);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _reset(BuildContext context) async {
    final ok = await showStyledConfirmDialog(
      context,
      icon: Icons.refresh_rounded,
      title: '¿Empezar de nuevo?',
      message: 'Se borrará todo lo que preparaste hasta ahora.',
      confirmLabel: 'Reiniciar',
      cancelLabel: 'Cancelar',
      destructive: true,
    );
    if (ok) studio.restart();
  }

  @override
  Widget build(BuildContext context) {
    final style = OutlinedButton.styleFrom(
      foregroundColor: StudioColors.primary,
      minimumSize: const Size(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
    final busy = studio.adding;
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: OutlinedButton.icon(onPressed: busy ? null : () => _edit(context), icon: const Icon(Icons.edit_rounded, size: 18), label: const Text('Editar'), style: style)),
            const SizedBox(width: 10),
            Expanded(child: OutlinedButton.icon(onPressed: busy ? null : onSave, icon: const Icon(Icons.bookmark_add_outlined, size: 18), label: const Text('Guardar'), style: style)),
            const SizedBox(width: 10),
            Expanded(child: OutlinedButton.icon(onPressed: busy ? null : () => _reset(context), icon: const Icon(Icons.refresh_rounded, size: 18), label: const Text('Reiniciar'), style: style)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: busy ? null : onAdd,
            style: FilledButton.styleFrom(backgroundColor: StudioColors.primary, minimumSize: const Size(0, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
            icon: busy
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                : const Icon(Icons.shopping_bag_rounded),
            label: Text(busy ? 'Agregando…' : 'Agregar al carrito · ${formatCop(studio.total)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          ),
        ),
      ],
    );
  }
}
