import 'package:flutter/material.dart';

import '../../animations/motion.dart';
import '../../models/cup_snapshot.dart';
import 'ambient_painter.dart';
import 'art_pour.dart';
import 'takeaway_cup_painter.dart';
import 'top_view_painter.dart';
import 'transition_painter.dart';

/// Escenario animado del vaso. Mantiene vivos el vapor y las ondas del
/// líquido; anima el desplazamiento del vaso entre secciones, la
/// llegada de copos o llamas, el cambio de cámara (lado → inclinada →
/// desde arriba), el vertido del latte art con su jarrita y el cierre
/// de la tapa.
class CupStage extends StatefulWidget {
  const CupStage({
    super.key,
    required this.snapshot,
    this.view = CupView.side,
    this.pourKind = PourKind.none,
    this.pourTick = 0,
    this.transition = StudioTransition.none,
    this.transitionTick = 0,
    this.transitionDir = 1,
    this.artTick = 0,
    this.ambient = false,
    this.lidOn = false,
  });

  final CupSnapshot snapshot;
  final CupView view;
  final PourKind pourKind;
  final int pourTick;
  final StudioTransition transition;
  final int transitionTick;
  final int transitionDir;
  final int artTick;

  /// Partículas de nieve o fuego en los bordes (desde la sección de base).
  final bool ambient;

  /// true cuando la bebida está terminada: baja la tapa.
  final bool lidOn;

  @override
  State<CupStage> createState() => _CupStageState();
}

class _CupStageState extends State<CupStage> with TickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(vsync: this, duration: const Duration(seconds: 10));
  late final AnimationController _fx = AnimationController(vsync: this, duration: const Duration(milliseconds: 950));
  late final AnimationController _temp = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));
  late final AnimationController _pour = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000));
  late final AnimationController _jug = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
  late final AnimationController _slide = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
  late final AnimationController _tilt = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
  late final AnimationController _top = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  late final AnimationController _lid = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));

  bool _reduced = false;

  @override
  void initState() {
    super.initState();
    final s = widget.snapshot;
    _temp.value = s.isHot ? 0 : 1;
    _pour.value = s.latteArt.isEmpty ? 0 : 1;
    _tilt.value = widget.view == CupView.tilt ? 1 : 0;
    _top.value = widget.view == CupView.top ? 1 : 0;
    _lid.value = widget.lidOn ? 1 : 0;
    _slide.value = 1;
    _jug.value = _jugWanted ? 1 : 0;
    _pour.addStatusListener((_) => _syncJug());
  }

  /// La jarrita se ve en la sección de arte latte mientras no haya un
  /// diseño terminado (oxigenando la leche) y durante el vertido.
  bool get _jugWanted => widget.view == CupView.tilt && (widget.snapshot.latteArt.isEmpty || _pour.isAnimating);

  void _syncJug() {
    if (!mounted) return;
    _jug.animateTo(_jugWanted ? 1 : 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = Motion.reduced(context);
    if (_reduced) {
      _loop.stop();
    } else if (!_loop.isAnimating) {
      _loop.repeat();
    }
  }

  @override
  void didUpdateWidget(CupStage old) {
    super.didUpdateWidget(old);
    final s = widget.snapshot;

    if (old.pourTick != widget.pourTick && widget.pourKind != PourKind.none && !_reduced) {
      _fx.forward(from: 0);
    }
    if (old.snapshot.isHot != s.isHot) {
      if (s.isHot) {
        _temp.reverse();
      } else {
        _temp.forward();
      }
    }
    if (old.transitionTick != widget.transitionTick && widget.transition != StudioTransition.none) {
      if (_reduced) {
        _slide.value = 1;
      } else {
        _slide.forward(from: 0);
      }
    }
    if (old.artTick != widget.artTick) {
      if (s.latteArt.isEmpty) {
        _pour.value = 0;
      } else if (_reduced) {
        _pour.value = 1;
      } else {
        _pour.forward(from: 0);
      }
    }
    if (old.view != widget.view) {
      _tilt.animateTo(widget.view == CupView.tilt ? 1 : 0);
      _top.animateTo(widget.view == CupView.top ? 1 : 0);
    }
    if (old.lidOn != widget.lidOn) {
      if (widget.lidOn) {
        _lid.forward();
      } else {
        _lid.reverse();
      }
    }
    _syncJug();
  }

  @override
  void dispose() {
    for (final c in [_loop, _fx, _temp, _pour, _jug, _slide, _tilt, _top, _lid]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final s = widget.snapshot;
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, box) => AnimatedBuilder(
          animation: Listenable.merge([_loop, _fx, _temp, _pour, _jug, _slide, _tilt, _top, _lid]),
          builder: (context, _) {
            final time = _loop.value * 10;
            final cold = Curves.easeInOut.transform(_temp.value);
            final slide = Curves.easeOutCubic.transform(_slide.value);
            final dx = (1 - slide) * -widget.transitionDir * box.maxWidth * 0.55;
            final topT = Curves.easeInOut.transform(_top.value);
            final artP = s.latteArt.isEmpty ? 0.0 : ((_pour.value - 0.1) / 0.8).clamp(0.0, 1.0).toDouble();

            return Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(painter: AmbientPainter(time: time, cold: cold, front: false, dark: dark)),
                if (topT < 1)
                  Opacity(
                    opacity: 1 - topT,
                    child: Transform.translate(
                      offset: Offset(dx, 0),
                      child: CustomPaint(
                        painter: TakeawayCupPainter(
                          snap: s,
                          time: time,
                          cold: cold,
                          effect: widget.pourKind,
                          effectT: _fx.value,
                          effectSeed: widget.pourTick,
                          artProgress: artP,
                          scene: ArtScene(jugShow: _jug.value, pourT: _pour.value, pouring: _pour.isAnimating && s.latteArt.isNotEmpty),
                          lid: _lid.value,
                          tilt: Curves.easeInOut.transform(_tilt.value),
                          dark: dark,
                        ),
                      ),
                    ),
                  ),
                if (topT > 0)
                  Opacity(
                    opacity: topT,
                    child: Transform.translate(
                      offset: Offset(dx, 0),
                      child: CustomPaint(
                        painter: TopViewPainter(
                          snap: s,
                          time: time,
                          effect: widget.pourKind,
                          effectT: _fx.value,
                          effectSeed: widget.pourTick,
                          dark: dark,
                        ),
                      ),
                    ),
                  ),
                IgnorePointer(
                  child: CustomPaint(
                    painter: TransitionPainter(kind: widget.transition, t: _slide.value, cold: !s.isHot, time: time),
                  ),
                ),
                if (widget.ambient)
                  IgnorePointer(child: CustomPaint(painter: AmbientPainter(time: time, cold: cold, front: true, dark: dark))),
              ],
            );
          },
        ),
      ),
    );
  }
}
