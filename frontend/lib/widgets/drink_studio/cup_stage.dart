import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/scheduler.dart';

import '../../animations/motion.dart';
import '../../models/cup_snapshot.dart';
import 'ambient_painter.dart';
import 'art_pour.dart';
import 'cup_geometry.dart';
import 'latte_pour_session.dart';
import 'takeaway_cup_painter.dart';
import 'top_view_painter.dart';
import 'transition_painter.dart';

/// Escenario animado del vaso. Mantiene vivos el vapor y las ondas del
/// líquido; anima el desplazamiento del vaso entre secciones, la
/// llegada de copos o llamas, el cambio de cámara (lado → inclinada →
/// desde arriba), el vertido interactivo del latte art con su jarrita
/// (que sigue al dedo) y el cierre de la tapa.
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
    this.ambient = false,
    this.lidOn = false,
    this.pour,
    this.interactive = false,
  });

  final CupSnapshot snapshot;
  final CupView view;
  final PourKind pourKind;
  final int pourTick;
  final StudioTransition transition;
  final int transitionTick;
  final int transitionDir;

  /// Partículas de nieve o fuego en los bordes (desde la sección de base).
  final bool ambient;

  /// true cuando la bebida está terminada: baja la tapa.
  final bool lidOn;

  /// Vertido interactivo del arte latte (null = sin arte interactivo,
  /// como en el resumen final).
  final LattePourSession? pour;

  /// true mientras el usuario puede verter con el dedo (etapa de arte).
  final bool interactive;

  @override
  State<CupStage> createState() => _CupStageState();
}

class _CupStageState extends State<CupStage> with TickerProviderStateMixin {
  /// Cuánto sube el punto de vertido respecto al dedo (para que el dedo
  /// no tape lo que se está rellenando). Solo con pantallas táctiles.
  static const double _fingerLift = 34;

  late final AnimationController _loop = AnimationController(vsync: this, duration: const Duration(seconds: 10));
  late final AnimationController _fx = AnimationController(vsync: this, duration: const Duration(milliseconds: 950));
  late final AnimationController _temp = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));
  late final AnimationController _jug = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
  late final AnimationController _slide = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
  late final AnimationController _tilt = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
  late final AnimationController _top = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  late final AnimationController _lid = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));

  /// Satisfacción al terminar el diseño (0 → 1; 1 = en reposo).
  late final AnimationController _done = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  /// Reloj de la simulación del vertido (solo corre en la etapa de arte).
  late final Ticker _pourTicker = createTicker(_onPourTick);
  Duration _lastTick = Duration.zero;
  int? _activePointer;
  int _doneSeen = 0;

  bool _reduced = false;

  @override
  void initState() {
    super.initState();
    final s = widget.snapshot;
    _temp.value = s.isHot ? 0 : 1;
    _tilt.value = widget.view == CupView.tilt ? 1 : 0;
    _top.value = widget.view == CupView.top ? 1 : 0;
    _lid.value = widget.lidOn ? 1 : 0;
    _slide.value = 1;
    _done.value = 1;
    _jug.value = _jugWanted ? 1 : 0;
    _doneSeen = widget.pour?.doneTick ?? 0;
    widget.pour?.addListener(_onSession);
    _syncTicker();
  }

  /// La jarrita se ve en la sección de arte latte mientras el diseño
  /// no esté terminado (oxigenando la leche y vertiendo).
  bool get _jugWanted => widget.view == CupView.tilt && !(widget.pour?.completed ?? false);

  void _syncJug() {
    if (!mounted) return;
    _jug.animateTo(_jugWanted ? 1 : 0);
  }

  bool get _pourActive => widget.pour != null && widget.view == CupView.tilt;

  void _syncTicker() {
    if (_pourActive) {
      if (!_pourTicker.isActive) {
        _lastTick = Duration.zero;
        _pourTicker.start();
      }
    } else if (_pourTicker.isActive) {
      _pourTicker.stop();
      _activePointer = null;
      widget.pour?.pointerUp();
    }
  }

  void _onPourTick(Duration elapsed) {
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    widget.pour?.tick(dt.clamp(0.0, 0.05).toDouble());
  }

  /// Arranca la animación de satisfacción en cuanto el diseño termina
  /// (sin esperar a que se reconstruya la pantalla: así no hay un
  /// parpadeo con el diseño terminado apareciendo antes de tiempo).
  void _onSession() {
    final p = widget.pour;
    if (p == null || p.doneTick == _doneSeen) return;
    _doneSeen = p.doneTick;
    if (_reduced) {
      _done.value = 1;
    } else {
      _done.forward(from: 0);
    }
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

    if (old.pour != widget.pour) {
      old.pour?.removeListener(_onSession);
      widget.pour?.addListener(_onSession);
      _doneSeen = widget.pour?.doneTick ?? 0;
    }
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
    _syncTicker();
    _syncJug();
  }

  @override
  void dispose() {
    widget.pour?.removeListener(_onSession);
    _pourTicker.dispose();
    for (final c in [_loop, _fx, _temp, _jug, _slide, _tilt, _top, _lid, _done]) {
      c.dispose();
    }
    super.dispose();
  }

  // ───────────── Gesto del vertido ─────────────

  /// Solo se vierte con la cámara ya acercada y el diseño sin terminar.
  bool get _canPour => widget.interactive && (widget.pour?.canPour ?? false) && widget.view == CupView.tilt && _tilt.value > 0.97;

  /// Posición del puntero sobre la superficie del café en coordenadas
  /// unitarias (las mismas de los diseños). Usa la misma geometría que
  /// el painter, con la cámara ya acercada.
  Offset _unitOf(PointerEvent e, Size box) {
    final s = widget.snapshot;
    final g = CupGeo(box, s.sizeFactor, tilt: 1);
    final (c, rx, ry) = g.surface(s.fill);
    var p = e.localPosition;
    if (e.kind == PointerDeviceKind.touch || e.kind == PointerDeviceKind.stylus) p = p.translate(0, -_fingerLift);
    return Offset((p.dx - c.dx) / (rx * ArtPour.kx), (p.dy - c.dy) / (ry * ArtPour.ky));
  }

  void _down(PointerDownEvent e, Size box) {
    if (_activePointer != null || !_canPour) return;
    _activePointer = e.pointer;
    widget.pour!.pointerDown(_unitOf(e, box));
  }

  void _move(PointerMoveEvent e, Size box) {
    if (e.pointer != _activePointer) return;
    widget.pour?.pointerMove(_unitOf(e, box));
  }

  void _up(PointerEvent e) {
    if (e.pointer != _activePointer) return;
    _activePointer = null;
    widget.pour?.pointerUp();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final s = widget.snapshot;
    final pr = widget.pour;
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, box) {
          final size = Size(box.maxWidth, box.maxHeight);
          return Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (e) => _down(e, size),
            onPointerMove: (e) => _move(e, size),
            onPointerUp: _up,
            onPointerCancel: _up,
            child: AnimatedBuilder(
              animation: Listenable.merge(<Listenable>[_loop, _fx, _temp, _jug, _slide, _tilt, _top, _lid, _done, if (pr != null) pr]),
              builder: (context, _) {
                final time = _loop.value * 10;
                final cold = Curves.easeInOut.transform(_temp.value);
                final slide = Curves.easeOutCubic.transform(_slide.value);
                final dx = (1 - slide) * -widget.transitionDir * box.maxWidth * 0.55;
                final topT = Curves.easeInOut.transform(_top.value);
                final scene = pr == null
                    ? const ArtScene()
                    : ArtScene(jugShow: _jug.value, lean: pr.lean, target: pr.jug, flow: pr.flow, progress: pr.progress);

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
                              scene: scene,
                              pour: pr,
                              artSettle: (_done.value / 0.25).clamp(0.0, 1.0).toDouble(),
                              celebrate: _done.value,
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
                    if (widget.ambient) IgnorePointer(child: CustomPaint(painter: AmbientPainter(time: time, cold: cold, front: true, dark: dark))),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
