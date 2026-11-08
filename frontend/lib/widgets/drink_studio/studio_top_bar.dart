import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/drink_studio_stage.dart';
import '../../providers/drink_studio_provider.dart';
import 'studio_colors.dart';
import 'studio_prefs_tiles.dart';
import '../../core/utils/studio_prefs.dart';

/// Encabezado del estudio: cerrar, nombre y los pasos numerados (se
/// puede volver a los ya vistos). DrinkStudio es un juego: no hay precios.
class StudioTopBar extends StatelessWidget {
  const StudioTopBar({super.key, required this.onClose});
  final VoidCallback onClose;

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
                    Text('Prepara tu latte', style: TextStyle(fontSize: 12, color: StudioColors.muted(dark))),
                  ],
                ),
              ),
              IconButton(tooltip: 'Ajustes del estudio', onPressed: () => showStudioSettingsSheet(context), icon: Icon(Icons.tune_rounded, color: StudioColors.muted(dark))),
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
                    // El tramo se «llena» de izquierda a derecha al avanzar.
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(color: StudioColors.line(dark), borderRadius: BorderRadius.circular(4)),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: i <= s.stepIndex ? 1.0 : 0.0),
                        duration: StudioPrefs.instance.animations ? const Duration(milliseconds: 450) : Duration.zero,
                        curve: Curves.easeOutCubic,
                        builder: (_, v, _) => Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: v,
                            child: DecoratedBox(decoration: BoxDecoration(gradient: StudioColors.brand, borderRadius: BorderRadius.circular(4))),
                          ),
                        ),
                      ),
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
            _Halo(
              on: state == _DotState.current,
              child: AnimatedContainer(
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
            ),
            const SizedBox(height: 2),
            Text(step.label, style: TextStyle(fontSize: 9.5, fontWeight: state == _DotState.current ? FontWeight.w800 : FontWeight.w600, color: active ? StudioColors.accent(dark) : StudioColors.muted(dark))),
          ],
        ),
      ),
    );
  }
}


/// Anillo que late suavemente alrededor del paso actual.
class _Halo extends StatefulWidget {
  const _Halo({required this.on, required this.child});
  final bool on;
  final Widget child;

  @override
  State<_Halo> createState() => _HaloState();
}

class _HaloState extends State<_Halo> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(_Halo old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final go = widget.on && StudioPrefs.instance.animations;
    if (go && !_c.isAnimating) {
      _c.repeat();
    } else if (!go && _c.isAnimating) {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final v = _c.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: widget.on && _c.isAnimating
                ? [BoxShadow(color: StudioColors.primary.withValues(alpha: 0.45 * (1 - v)), blurRadius: 2, spreadRadius: 9 * v)]
                : const [],
          ),
          child: child,
        );
      },
    );
  }
}
