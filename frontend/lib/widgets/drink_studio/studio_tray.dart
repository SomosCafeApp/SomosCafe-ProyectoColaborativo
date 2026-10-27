import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/drink_studio_stage.dart';
import '../../providers/drink_studio_provider.dart';
import 'studio_colors.dart';
import 'studio_panels.dart';

/// Bandeja inferior: el panel de la sección activa y los controles
/// para avanzar y regresar sin perder lo elegido.
class StudioTray extends StatelessWidget {
  const StudioTray({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<DrinkStudioProvider>();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final steps = s.steps;
    final nextStep = s.stepIndex + 1 < steps.length ? steps[s.stepIndex + 1] : StudioStep.result;

    return Container(
      decoration: BoxDecoration(
        color: StudioColors.panel(dark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(position: Tween(begin: Offset(0.08 * s.transitionDir, 0), end: Offset.zero).animate(anim), child: child),
                ),
                child: KeyedSubtree(key: ValueKey(s.step), child: buildStudioPanel(s.step)),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Row(
                children: [
                  if (!s.isFirstStep) ...[
                    OutlinedButton.icon(
                      onPressed: s.back,
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Atrás'),
                      style: OutlinedButton.styleFrom(foregroundColor: StudioColors.primary, minimumSize: const Size(0, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: s.next,
                      iconAlignment: IconAlignment.end,
                      style: FilledButton.styleFrom(backgroundColor: StudioColors.primary, minimumSize: const Size(0, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                      icon: Icon(nextStep == StudioStep.result ? Icons.check_circle_rounded : Icons.arrow_forward_rounded),
                      label: Text(nextStep == StudioStep.result ? 'Ver mi bebida' : 'Siguiente · ${nextStep.label}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
