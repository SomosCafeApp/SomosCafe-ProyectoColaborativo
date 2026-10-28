import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/cup_snapshot.dart';
import 'latte_art_shapes.dart';
import 'studio_colors.dart';
import 'topping_painters.dart';

/// Todo lo que se ve sobre la superficie de la bebida (elipse de la
/// boca del vaso): remolino de la mezcla, jarabes, endulzantes, latte
/// art y toppings.
class SurfaceDecor {
  SurfaceDecor._();

  static void syrups(Canvas canvas, Offset c, double rx, double ry, List<String> names) {
    for (var i = 0; i < names.length; i++) {
      final color = StudioColors.accentFor(names[i]);
      final x = c.dx - rx * 0.45 + i * rx * 0.45;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, c.dy), width: rx * 0.5, height: ry * 0.7),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..color = color.withValues(alpha: 0.85),
      );
      canvas.drawCircle(Offset(x, c.dy), 2.6, Paint()..color = color);
    }
  }

  /// Latte art dibujándose poco a poco ([progress] 0..1).
  static void art(Canvas canvas, Offset c, double rx, double ry, String design, double progress) {
    if (design.isEmpty || progress <= 0) return;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(rx * 0.8, ry * 0.86);
    LatteArtShapes.paintProgress(canvas, design, progress);
    canvas.restore();
  }

  /// Toppings sobre la superficie (ver `ToppingPainters`). Con latte art
  /// ([hasArt]) la crema forma una corona y el resto se reparte por el
  /// borde: el diseño del centro siempre queda visible.
  static void toppings(Canvas canvas, Offset c, double rx, double ry, List<String> names, {required bool hasArt, bool topView = false, Map<String, int> qty = const {}}) {
    ToppingPainters.paint(canvas, c, rx, ry, names, qty, hasArt: hasArt, topView: topView);
  }

  /// Efecto de "verter" sobre la boca del vaso.
  static void pour(Canvas canvas, Offset c, double rx, double ry, CupSnapshot snap, PourKind kind, double t, int seed, double time) {
    final env = math.sin(t * math.pi);
    final rnd = math.Random(seed);
    if (kind == PourKind.sweetener || kind == PourKind.topping) {
      final color = kind == PourKind.sweetener ? Colors.white : StudioColors.latte;
      for (var i = 0; i < 16; i++) {
        final p = (t * 1.25 - i * 0.025).clamp(0.0, 1.0).toDouble();
        final px = c.dx + (rnd.nextDouble() - 0.5) * rx * 1.2;
        canvas.drawCircle(Offset(px, -8 + (c.dy + 8) * p), 2.2, Paint()..color = color.withValues(alpha: (1 - p) * 0.9 + 0.1));
      }
      return;
    }
    final color = kind == PourKind.milk ? snap.milkColor : (kind == PourKind.syrup ? StudioColors.caramel : snap.baseColor);
    final stream = Path()..moveTo(c.dx, -8);
    for (var k = 1; k <= 10; k++) {
      stream.lineTo(c.dx + math.sin(time * 9 + k) * 1.4, -8 + (c.dy + 8) * k / 10);
    }
    canvas.drawPath(
      stream,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 4 + 5 * env
        ..color = color.withValues(alpha: 0.92),
    );
    canvas.drawOval(
      Rect.fromCenter(center: c, width: rx * 2 * t * 0.9, height: ry * 2 * t * 0.9),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = Colors.white.withValues(alpha: 0.6 * (1 - t)),
    );
  }
}
