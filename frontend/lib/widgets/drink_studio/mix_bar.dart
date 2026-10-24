import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/drink_studio_provider.dart';
import 'studio_colors.dart';

/// Barra lateral de mezcla: se desliza el dedo hacia arriba y abajo
/// (o se mantiene pulsada) para mover la cuchara dentro del vaso. La
/// mezcla se ve en el líquido y en el remolino de la superficie.
class MixBar extends StatefulWidget {
  const MixBar({super.key});

  @override
  State<MixBar> createState() => _MixBarState();
}

class _MixBarState extends State<MixBar> {
  Timer? _hold;
  double _t = 0.5;
  double _phase = 0;

  void _startHold(DrinkStudioProvider s) {
    _hold?.cancel();
    HapticFeedback.mediumImpact();
    _hold = Timer.periodic(const Duration(milliseconds: 40), (_) {
      _phase += 0.28;
      setState(() => _t = 0.5 + 0.5 * math.sin(_phase));
      s.setSpoon(_t);
      s.addMix(0.012);
    });
  }

  void _stop(DrinkStudioProvider s) {
    _hold?.cancel();
    _hold = null;
    s.setSpoon(null);
  }

  @override
  void dispose() {
    _hold?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<DrinkStudioProvider>();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final done = s.mix >= 1;
    return LayoutBuilder(
      builder: (context, box) {
        final track = math.max(60.0, box.maxHeight - 76);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragStart: (_) => s.setSpoon(_t),
          onVerticalDragUpdate: (d) {
            final next = (_t + d.delta.dy / track).clamp(0.0, 1.0).toDouble();
            s.addMix(d.delta.dy.abs() / track * 0.5);
            setState(() => _t = next);
            s.setSpoon(next);
          },
          onVerticalDragEnd: (_) => _stop(s),
          onVerticalDragCancel: () => _stop(s),
          onLongPressStart: (_) => _startHold(s),
          onLongPressEnd: (_) => _stop(s),
          onLongPressCancel: () => _stop(s),
          onTap: () {
            s.addMix(0.1);
            s.setSpoon(0.7);
            Future<void>.delayed(const Duration(milliseconds: 500), () => s.setSpoon(null));
          },
          child: Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: StudioColors.panel(dark).withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: StudioColors.primary.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                Icon(done ? Icons.check_circle_rounded : Icons.sync_rounded, size: 20, color: StudioColors.primary),
                const SizedBox(height: 4),
                Expanded(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(width: 8, decoration: BoxDecoration(color: StudioColors.soft(dark), borderRadius: BorderRadius.circular(6))),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          width: 8,
                          height: track * s.mix,
                          decoration: BoxDecoration(color: StudioColors.primary, borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                      Positioned(
                        top: (track - 34) * _t,
                        child: const _SpoonHandle(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(done ? 'Lista' : '${(s.mix * 100).round()}%', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: StudioColors.text(dark))),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SpoonHandle extends StatelessWidget {
  const _SpoonHandle();

  @override
  Widget build(BuildContext context) => Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: StudioColors.cream,
          border: Border.all(color: StudioColors.ink, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: const Icon(Icons.unfold_more_rounded, size: 20, color: StudioColors.ink),
      );
}
