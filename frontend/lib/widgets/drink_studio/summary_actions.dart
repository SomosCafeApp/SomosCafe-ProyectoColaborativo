import 'package:flutter/material.dart';

import '../../core/utils/money_format.dart';
import '../../models/drink_studio_stage.dart';
import '../../providers/drink_studio_provider.dart';
import '../common/styled_confirm_dialog.dart';
import 'studio_colors.dart';

/// Acciones de la pantalla final: volver a personalizar, agregar al
/// carrito y, en pequeño, guardar la receta o empezar de nuevo.
class SummaryActions extends StatelessWidget {
  const SummaryActions({super.key, required this.studio, required this.onAdd, required this.onSave});
  final DrinkStudioProvider studio;
  final VoidCallback onAdd;
  final VoidCallback onSave;

  /// Elegir qué parte de la bebida volver a personalizar.
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
    final busy = studio.adding;
    final minor = TextButton.styleFrom(foregroundColor: StudioColors.primary, visualDensity: VisualDensity.compact, textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: busy ? null : () => _edit(context),
              icon: const Icon(Icons.tune_rounded, size: 18),
              label: const Text('Personalizar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: StudioColors.primary,
                side: const BorderSide(color: StudioColors.primary, width: 1.6),
                minimumSize: const Size(0, 54),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: busy ? null : StudioColors.brand,
                  color: busy ? StudioColors.latte.withValues(alpha: 0.5) : null,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: busy ? const [] : [BoxShadow(color: StudioColors.primary.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 6))],
                ),
                child: FilledButton.icon(
                  onPressed: busy ? null : onAdd,
                  style: FilledButton.styleFrom(backgroundColor: Colors.transparent, disabledBackgroundColor: Colors.transparent, shadowColor: Colors.transparent, minimumSize: const Size(0, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  icon: busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white)) : const Icon(Icons.shopping_bag_rounded),
                  label: Text(busy ? 'Agregando…' : 'Agregar · ${formatCop(studio.total)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(onPressed: busy ? null : onSave, icon: const Icon(Icons.bookmark_add_outlined, size: 17), label: const Text('Guardar receta'), style: minor),
            TextButton.icon(onPressed: busy ? null : () => _reset(context), icon: const Icon(Icons.refresh_rounded, size: 17), label: const Text('Empezar de nuevo'), style: minor),
          ],
        ),
      ],
    );
  }
}
