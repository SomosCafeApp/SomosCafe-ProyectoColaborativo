import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/money_format.dart';
import '../../models/drink_studio_stage.dart';
import '../../providers/drink_studio_provider.dart';
import 'studio_colors.dart';
import 'studio_prefs_tiles.dart';
import '../../core/utils/studio_prefs.dart';

/// Encabezado del estudio: cerrar, nombre, guardar receta, total
/// actualizado y los pasos numerados (se puede volver a los ya vistos).
class StudioTopBar extends StatelessWidget {
  const StudioTopBar({super.key, required this.onClose, required this.onSave});
  final VoidCallback onClose;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<DrinkStudioProvider>();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final steps = s.steps;
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
                    Text(s.product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -0.2, color: StudioColors.text(dark))),
                    Text('Prepara tu bebida', style: TextStyle(fontSize: 12, color: StudioColors.muted(dark))),
                  ],
                ),
              ),
              IconButton(tooltip: 'Ajustes del estudio', onPressed: () => showStudioSettingsSheet(context), icon: Icon(Icons.tune_rounded, color: StudioColors.muted(dark))),
              IconButton(tooltip: 'Guardar receta', onPressed: onSave, icon: const Icon(Icons.bookmark_add_outlined, color: StudioColors.primary)),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                child: Container(
                  key: ValueKey(s.total),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: StudioColors.brand,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: StudioColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: Text(formatCop(s.total), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.1)),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              for (var i = 0; i < steps.length; i++) ...[
                if (i > 0)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(color: i <= s.stepIndex ? StudioColors.primary : StudioColors.soft(dark), borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                _Dot(
                  number: i + 1,
                  step: steps[i],
                  state: i < s.stepIndex ? _DotState.done : (i == s.stepIndex ? _DotState.current : _DotState.todo),
                  onTap: i <= s.furthest && i != s.stepIndex ? () => s.goToStep(steps[i]) : null,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

enum _DotState { done, current, todo }

class _Dot extends StatelessWidget {
  const _Dot({required this.number, required this.step, required this.state, this.onTap});
  final int number;
  final StudioStep step;
  final _DotState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final active = state != _DotState.todo;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              width: state == _DotState.current ? 30 : 24,
              height: state == _DotState.current ? 30 : 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? StudioColors.primary : StudioColors.soft(dark),
                boxShadow: state == _DotState.current ? [BoxShadow(color: StudioColors.primary.withValues(alpha: 0.4), blurRadius: 8)] : null,
              ),
              child: Center(
                // El check "salta" al completar la etapa.
                child: AnimatedSwitcher(
                  duration: StudioPrefs.instance.animations ? const Duration(milliseconds: 380) : Duration.zero,
                  switchInCurve: Curves.easeOutBack,
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                  child: state == _DotState.done
                      ? const Icon(Icons.check_rounded, key: ValueKey('done'), size: 15, color: Colors.white)
                      : Icon(step.icon, key: const ValueKey('icon'), size: state == _DotState.current ? 16 : 13, color: active ? Colors.white : StudioColors.muted(dark)),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(step.label, style: TextStyle(fontSize: 9.5, fontWeight: state == _DotState.current ? FontWeight.w800 : FontWeight.w600, color: active ? StudioColors.primary : StudioColors.muted(dark))),
          ],
        ),
      ),
    );
  }
}
