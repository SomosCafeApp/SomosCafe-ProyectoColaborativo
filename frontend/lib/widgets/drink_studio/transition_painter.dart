import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/cup_snapshot.dart';
import 'ambient_painter.dart';

/// Detalles que acompañan los cambios del estudio. Todas las partículas
/// son [ThermalParticle]: llamas que se vuelven copos (y al revés) con un
/// cambio continuo de forma, tamaño, opacidad y movimiento.
/// - tempIntro: un copo y una llama (las dos temperaturas) que pasan.
/// - tempBurst: anillo de partículas que se transforman en la temperatura elegida.
/// - enjambre (swap): al cambiar de caliente a frío (o al revés) un círculo
///   de partículas se abre alrededor del vaso y se transforma.
class TransitionPainter extends CustomPainter {
  TransitionPainter({
    required this.kind,
    required this.t,
    required this.cold,
    required this.time,
    this.swap = -1,
    this.swapToCold = true,
    this.dark = false,
    this.quality = 1,
  });

  final StudioTransition kind;

  /// 0..1: avance de la animación.
  final double t;
  final bool cold;
  final double time;

  /// 0..1: avance del cambio de temperatura en curso (-1 = ninguno).
  final double swap;
  final bool swapToCold;
  final bool dark;
  final double quality;

  @override
  void paint(Canvas canvas, Size size) {
    if (swap > 0 && swap < 1) _swarm(canvas, size, swap);
    if (t <= 0 || t >= 1) return;
    final fade = math.sin(t * math.pi).clamp(0.0, 1.0).toDouble();
    switch (kind) {
      case StudioTransition.tempIntro:
        ThermalParticle.paint(canvas, Offset(size.width * (0.2 + 0.1 * t), size.height * (0.5 - 0.15 * t)), 8 + 3 * fade, 1, fade, time, time, dark);
        ThermalParticle.paint(canvas, Offset(size.width * (0.8 - 0.1 * t), size.height * (0.5 - 0.15 * t)), 7 + 3 * fade, 0, fade, time, time, dark);
      case StudioTransition.tempBurst:
        _burst(canvas, Offset(size.width / 2, size.height * 0.5), size, fade);
      case StudioTransition.plain:
      case StudioTransition.none:
        break;
    }
  }

  static double _smooth(double v) {
    final x = v.clamp(0.0, 1.0).toDouble();
    return x * x * (3 - 2 * x);
  }

  /// Estallido breve: las partículas salen del centro ya transformándose
  /// hacia la temperatura elegida.
  void _burst(Canvas canvas, Offset c, Size size, double fade) {
    final n = (cold ? 14 : 12) * quality.clamp(0.5, 1.0).toDouble();
    final spread = math.min(size.width, size.height) * (0.18 + 0.4 * Curves.easeOutCubic.transform(t));
    final to = cold ? 1.0 : 0.0;
    final m = (1 - to) + (to - (1 - to)) * _smooth(t * 1.4);
    for (var i = 0; i < n.round(); i++) {
      final a = i / n * math.pi * 2 + t * 0.9;
      final r = spread * (0.75 + 0.25 * math.sin(i * 2.3));
      final p = c + Offset(math.cos(a) * r, math.sin(a) * r * 0.9 - (cold ? -1 : 1) * t * 24);
      ThermalParticle.paint(canvas, p, 6.5 + 4 * fade, m, fade * 0.9, a + time, time, dark);
    }
  }

  /// Anillo que se abre alrededor del vaso mientras la bebida cambia de
  /// temperatura: nacen como lo contrario y terminan siendo lo elegido.
  void _swarm(Canvas canvas, Size size, double p) {
    final n = (16 * quality.clamp(0.5, 1.0)).round();
    final c = Offset(size.width / 2, size.height * 0.52);
    final env = math.sin(p * math.pi);
    final radius = size.shortestSide * (0.14 + 0.3 * Curves.easeOutCubic.transform(p));
    final m = swapToCold ? _smooth(p) : 1 - _smooth(p);
    for (var i = 0; i < n; i++) {
      final a = i / n * math.pi * 2 + p * 1.4;
      final wobble = 1 + 0.12 * math.sin(i * 3.1 + p * 6);
      final pos = c + Offset(math.cos(a), math.sin(a) * 0.9) * radius * wobble;
      // Las que se enfrían caen un poco; las que se calientan suben.
      final drift = (swapToCold ? 1 : -1) * p * 14;
      ThermalParticle.paint(canvas, pos.translate(0, drift), 5.5 + 4 * env, m, env * 0.85, a + time * 0.6, time, dark);
    }
  }

  @override
  bool shouldRepaint(covariant TransitionPainter old) => true;
}
