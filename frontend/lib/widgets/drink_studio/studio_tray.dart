import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/drink_studio_stage.dart';
import '../../providers/drink_studio_provider.dart';
import '../common/styled_confirm_dialog.dart';
import 'studio_colors.dart';
import 'studio_panels.dart';

/// Bandeja inferior: el panel de la sección activa y los controles
/// para avanzar y regresar sin perder lo elegido.
class StudioTray extends StatelessWidget {
  const StudioTray({super.key});

  /// Avanza; si el arte latte quedó a medias, avisa antes de dejarlo.
  Future<void> _next(BuildContext context, DrinkStudioProvider s) async {
    if (s.step == StudioStep.art && s.artPending) {
      final percent = (s.pour.progress * 100).round();
      final skip = await showStyledConfirmDialog(
        context,
        icon: Icons.brush_rounded,
        title: 'Tu arte latte va al $percent %',
        message: 'Si sigues ahora, la bebida quedará sin arte latte. Tu avance se guarda por si quieres volver.',
        confirmLabel: 'Continuar sin arte',
        cancelLabel: 'Seguir vertiendo',
        destructive: false,
      );
      if (!skip || !context.mounted) return;
    }
    s.next();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<DrinkStudioProvider>();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final steps = s.steps;
    final nextStep = s.stepIndex + 1 < steps.length ? steps[s.stepIndex + 1] : StudioStep.result;

    return Container(
      decoration: BoxDecoration(
        color: StudioColors.panel(dark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), blurRadius: 24, offset: const Offset(0, -6))],
      ),
      child: Column(
        children: [
          // Asa decorativa de la bandeja.
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(width: 38, height: 4, decoration: BoxDecoration(color: StudioColors.muted(dark).withValues(alpha: 0.3), borderRadius: BorderRadius.circular(4))),
          ),
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
                      style: OutlinedButton.styleFrom(foregroundColor: StudioColors.primary, minimumSize: const Size(0, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (s.canResetStep) ...[
                    IconButton.outlined(
                      tooltip: 'Reiniciar esta etapa',
                      onPressed: s.resetCurrentStep,
                      icon: const Icon(Icons.restart_alt_rounded),
                      style: IconButton.styleFrom(foregroundColor: StudioColors.primary, minimumSize: const Size(54, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: StudioColors.brand,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: StudioColors.primary.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 6))],
                      ),
                      child: FilledButton.icon(
                        onPressed: () => _next(context, s),
                        iconAlignment: IconAlignment.end,
                        style: FilledButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, minimumSize: const Size(0, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        icon: Icon(nextStep == StudioStep.result ? Icons.check_circle_rounded : Icons.arrow_forward_rounded),
                        label: Text(nextStep == StudioStep.result ? 'Ver mi bebida' : 'Siguiente · ${nextStep.label}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.1)),
                      ),
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
