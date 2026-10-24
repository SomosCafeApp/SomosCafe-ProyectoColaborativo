import 'package:flutter/material.dart';

import '../../animations/motion.dart';
import '../../models/cup_snapshot.dart';
import 'ambient_painter.dart';
import 'takeaway_cup_painter.dart';

/// Escenario animado del vaso. Mantiene vivos el vapor, el líquido y
/// las ondas de calor; anima la transición caliente ↔ frío (la
/// escarcha avanza desde los bordes), el vertido de ingredientes, la
/// vista previa del latte art y el cierre de la tapa.
class CupStage extends StatefulWidget {
  const CupStage({
    super.key,
    required this.snapshot,
    this.pourKind = PourKind.none,
    this.pourTick = 0,
    this.lidOn = false,
  });

  final CupSnapshot snapshot;
  final PourKind pourKind;
  final int pourTick;

  /// true cuando la bebida está terminada: baja la tapa.
  final bool lidOn;

  @override
  State<CupStage> createState() => _CupStageState();
}

class _CupStageState extends State<CupStage> with TickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(vsync: this, duration: const Duration(seconds: 10));
  late final AnimationController _fx = AnimationController(vsync: this, duration: const Duration(milliseconds: 950));
  late final AnimationController _temp = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400), value: 0);
  late final AnimationController _art = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
  late final AnimationController _lid = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));

  @override
  void initState() {
    super.initState();
    _temp.value = widget.snapshot.isHot ? 0 : 1;
    _art.value = widget.snapshot.latteArt.isEmpty ? 0 : 1;
    _lid.value = widget.lidOn ? 1 : 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respeta "reducir animaciones" del sistema.
    if (Motion.reduced(context)) {
      _loop.stop();
    } else if (!_loop.isAnimating) {
      _loop.repeat();
    }
  }

  @override
  void didUpdateWidget(CupStage old) {
    super.didUpdateWidget(old);
    final reduced = Motion.reduced(context);
    final s = widget.snapshot;

    if (old.pourTick != widget.pourTick && widget.pourKind != PourKind.none && !reduced) {
      _fx.forward(from: 0);
    }
    if (old.snapshot.isHot != s.isHot) {
      // Escarcha progresiva al enfriar; se disipa al calentar.
      if (s.isHot) {
        _temp.reverse();
      } else {
        _temp.forward();
      }
    }
    if (old.snapshot.latteArt != s.latteArt) {
      if (s.latteArt.isEmpty) {
        _art.value = 0;
      } else {
        _art.forward(from: 0);
      }
    }
    if (old.lidOn != widget.lidOn) {
      if (widget.lidOn) {
        _lid.forward();
      } else {
        _lid.reverse();
      }
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    _fx.dispose();
    _temp.dispose();
    _art.dispose();
    _lid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_loop, _fx, _temp, _art, _lid]),
        builder: (context, _) {
          final time = _loop.value * 10;
          final cold = Curves.easeInOut.transform(_temp.value);
          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: AmbientPainter(time: time, cold: cold, front: false, dark: dark)),
              CustomPaint(
                painter: TakeawayCupPainter(
                  snap: widget.snapshot,
                  time: time,
                  cold: cold,
                  effect: widget.pourKind,
                  effectT: _fx.value,
                  effectSeed: widget.pourTick,
                  artT: Curves.easeOutBack.transform(_art.value).clamp(0.0, 1.0).toDouble(),
                  lid: _lid.value,
                  dark: dark,
                ),
              ),
              IgnorePointer(child: CustomPaint(painter: AmbientPainter(time: time, cold: cold, front: true, dark: dark))),
            ],
          );
        },
      ),
    );
  }
}
