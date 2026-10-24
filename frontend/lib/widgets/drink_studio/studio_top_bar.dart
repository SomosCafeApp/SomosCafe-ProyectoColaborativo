import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/money_format.dart';
import '../../providers/drink_studio_provider.dart';
import 'studio_colors.dart';

/// Encabezado del estudio: cerrar, nombre, guardar receta, total
/// actualizado y una barra con el progreso de la preparación.
class StudioTopBar extends StatelessWidget {
  const StudioTopBar({super.key, required this.onClose, required this.onSave});
  final VoidCallback onClose;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<DrinkStudioProvider>();
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
          child: Row(
            children: [
              IconButton(tooltip: 'Cerrar', onPressed: onClose, icon: Icon(Icons.close_rounded, color: StudioColors.text(dark))),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: StudioColors.text(dark))),
                    Text('Prepara tu bebida', style: TextStyle(fontSize: 12, color: StudioColors.muted(dark))),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Guardar receta',
                onPressed: onSave,
                icon: const Icon(Icons.bookmark_add_outlined, color: StudioColors.primary),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                child: Container(
                  key: ValueKey(s.total),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: StudioColors.primary.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
                  child: Text(formatCop(s.total), style: const TextStyle(fontWeight: FontWeight.w900, color: StudioColors.primary)),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: s.progress),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => LinearProgressIndicator(minHeight: 5, value: v, color: StudioColors.primary, backgroundColor: StudioColors.soft(dark)),
            ),
          ),
        ),
      ],
    );
  }
}
