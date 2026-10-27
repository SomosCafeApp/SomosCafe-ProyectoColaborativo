import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/cup_snapshot.dart';
import 'latte_art_shapes.dart';
import 'studio_colors.dart';

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

  static void sweeteners(Canvas canvas, Offset c, double rx, double ry, int count) {
    final rnd = math.Random(11);
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    for (var i = 0; i < count * 9; i++) {
      final a = rnd.nextDouble() * math.pi * 2, d = math.sqrt(rnd.nextDouble()) * 0.8;
      canvas.drawRect(Rect.fromCenter(center: Offset(c.dx + math.cos(a) * rx * d, c.dy + math.sin(a) * ry * d), width: 2.6, height: 2.6), paint);
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

  /// Corona de crema batida alrededor del borde (deja libre el centro).
  static void creamRing(Canvas canvas, Offset c, double rx, double ry) {
    const n = 16;
    for (var i = 0; i < n; i++) {
      final a = i / n * math.pi * 2;
      final p = Offset(c.dx + math.cos(a) * rx * 0.86, c.dy + math.sin(a) * ry * 0.86);
      final rect = Rect.fromCenter(center: p, width: rx * 0.19, height: math.max(ry * 0.5, rx * 0.1));
      canvas.drawOval(rect, Paint()..color = StudioColors.cream);
      canvas.drawOval(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = StudioColors.latte,
      );
      canvas.drawCircle(p.translate(-rect.width * 0.15, -rect.height * 0.15), rect.width * 0.12, Paint()..color = Colors.white.withValues(alpha: 0.8));
    }
  }

  /// Toppings sobre la superficie. Con latte art ([hasArt]) la crema
  /// forma una corona y el resto se reparte por el borde: el diseño
  /// del centro siempre queda visible.
  static void toppings(Canvas canvas, Offset c, double rx, double ry, List<String> names, {required bool hasArt, bool topView = false}) {
    final rnd = math.Random(5);
    Offset spot() {
      final a = rnd.nextDouble() * math.pi * 2;
      final d = hasArt ? 0.6 + rnd.nextDouble() * 0.28 : math.sqrt(rnd.nextDouble()) * 0.85;
      return Offset(c.dx + math.cos(a) * rx * d, c.dy + math.sin(a) * ry * d);
    }

    for (final name in names) {
      final n = name.toLowerCase();
      if (n.contains('crema') || n.contains('whip')) {
        if (hasArt) {
          creamRing(canvas, c, rx, ry);
        } else if (topView) {
          // Desde arriba: remolinos concentrados de crema con su punta.
          for (var i = 0; i < 4; i++) {
            final r = rx * (0.62 - i * 0.14);
            canvas.drawCircle(c, r, Paint()..color = StudioColors.cream);
            canvas.drawCircle(
              c,
              r,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.4
                ..color = StudioColors.latte.withValues(alpha: 0.8),
            );
          }
          canvas.drawCircle(c.translate(-rx * 0.06, -rx * 0.06), rx * 0.07, Paint()..color = Colors.white.withValues(alpha: 0.9));
        } else {
          for (var i = 0; i < 3; i++) {
            final w = rx * (1.2 - i * 0.34), cy = c.dy - ry * 0.4 - i * ry * 0.8;
            canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, cy), width: w, height: ry * 1.6), Paint()..color = StudioColors.cream);
            canvas.drawOval(
              Rect.fromCenter(center: Offset(c.dx, cy), width: w, height: ry * 1.6),
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.2
                ..color = StudioColors.latte,
            );
          }
        }
      } else if (n.contains('caramel')) {
        final path = Path();
        for (var i = 0; i <= 10; i++) {
          final x = c.dx - rx * 0.7 + rx * 1.4 * i / 10;
          final y = c.dy + (i.isEven ? -1 : 1) * ry * (hasArt ? 0.78 : 0.6);
          i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
        }
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 3
            ..color = StudioColors.caramel,
        );
      } else if (n.contains('chispa') || n.contains('chip') || n.contains('sprinkle')) {
        const colors = [Color(0xFF3B2416), Color(0xFFF3E2C3), Color(0xFFB5793F)];
        for (var i = 0; i < 20; i++) {
          final p = spot();
          canvas.save();
          canvas.translate(p.dx, p.dy);
          canvas.rotate(rnd.nextDouble() * math.pi);
          canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 5.4, height: 2.6), const Radius.circular(1.3)), Paint()..color = colors[i % 3]);
          canvas.restore();
        }
      } else {
        final color = n.contains('canela') || n.contains('cinn') ? const Color(0xFF8A4B2A) : StudioColors.latte;
        for (var i = 0; i < 30; i++) {
          canvas.drawCircle(spot(), 1.1 + rnd.nextDouble() * 0.9, Paint()..color = color.withValues(alpha: 0.9));
        }
      }
    }
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
