import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/cup_snapshot.dart';
import 'latte_art_shapes.dart';
import 'studio_colors.dart';

/// Escena del arte latte: la jarrita de leche (con su oxigenación),
/// el chorro y el vertido.
class ArtScene {
  const ArtScene({this.jugShow = 0, this.pourT = 0, this.pouring = false});

  /// 0..1: qué tan visible está la jarrita.
  final double jugShow;

  /// 0..1: progreso del vertido en curso.
  final double pourT;
  final bool pouring;
}

class ArtPour {
  ArtPour._();

  static double _seg(double p, double a, double b) => ((p - a) / (b - a)).clamp(0.0, 1.0).toDouble();

  /// Dibuja la jarrita y el chorro sobre la superficie ([c], [rx], [ry]).
  static void paint(Canvas canvas, Offset c, double rx, double ry, double jugSize, CupSnapshot snap, String design, ArtScene scene, double time) {
    if (scene.jugShow <= 0) return;

    // Posición y ángulo: reposo a la derecha → sobre la taza, inclinada.
    final lean = scene.pouring
        ? Curves.easeInOut.transform(_seg(scene.pourT, 0, 0.12)) * (1 - Curves.easeInOut.transform(_seg(scene.pourT, 0.9, 1)))
        : 0.0;
    final rest = Offset(c.dx + rx * 1.55, c.dy - ry * 1.9);
    final over = Offset(c.dx + rx * 0.95, c.dy - ry * 1.15);
    final pos = Offset.lerp(rest, over, lean)!;
    var angle = -0.75 * lean;
    if (!scene.pouring) angle += math.sin(time * 5) * 0.04; // vibra mientras airea

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);
    canvas.saveLayer(null, Paint()..color = Colors.white.withValues(alpha: scene.jugShow.clamp(0.0, 1.0).toDouble()));
    _jug(canvas, jugSize, snap, scene, time);
    canvas.restore();
    canvas.restore();

    // Chorro de leche desde el pico hasta el punto de vertido.
    if (scene.pouring && scene.pourT > 0.1 && scene.pourT < 0.92) {
      final p = _seg(scene.pourT, 0.1, 0.9);
      final unit = LatteArtShapes.pourPoint(design, p);
      final target = Offset(c.dx + unit.dx * rx * 0.8, c.dy + unit.dy * ry * 0.86);
      final local = Offset(-jugSize * 0.62, -jugSize * 0.45);
      final spout = pos +
          Offset(
            local.dx * math.cos(angle) - local.dy * math.sin(angle),
            local.dx * math.sin(angle) + local.dy * math.cos(angle),
          );
      final path = Path()..moveTo(spout.dx, spout.dy);
      path.quadraticBezierTo((spout.dx + target.dx) / 2 - 4, spout.dy + (target.dy - spout.dy) * 0.2, target.dx, target.dy);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = math.max(3, jugSize * 0.07)
          ..color = StudioColors.cream,
      );
      canvas.drawCircle(target, math.max(3.4, jugSize * 0.06), Paint()..color = StudioColors.cream);
    }
  }

  /// Jarrita de acero con leche, burbujas y vapor de oxigenación.
  static void _jug(Canvas canvas, double s, CupSnapshot snap, ArtScene scene, double time) {
    final body = Path()
      ..moveTo(-s * 0.5, -s * 0.35)
      ..lineTo(s * 0.5, -s * 0.35)
      ..lineTo(s * 0.38, s * 0.5)
      ..quadraticBezierTo(0, s * 0.62, -s * 0.38, s * 0.5)
      ..close();
    // Pico a la izquierda.
    final spout = Path()
      ..moveTo(-s * 0.5, -s * 0.35)
      ..lineTo(-s * 0.68, -s * 0.5)
      ..lineTo(-s * 0.36, -s * 0.35)
      ..close();
    final steel = Paint()..color = const Color(0xFFD7D2CB);
    canvas.drawPath(spout, steel);
    canvas.drawPath(body, steel);

    // Leche dentro.
    canvas.save();
    canvas.clipPath(body);
    canvas.drawRect(Rect.fromLTRB(-s, -s * 0.12, s, s), Paint()..color = snap.milkColor);
    // Burbujas de aireación que suben.
    final oxy = scene.pouring ? 0.0 : 1.0;
    for (var i = 0; i < 6; i++) {
      final ph = (time * 0.9 + i * 0.37) % 1.0;
      canvas.drawCircle(
        Offset(-s * 0.25 + i * s * 0.1, s * 0.45 - ph * s * 0.55),
        s * 0.035 * (0.6 + (i % 3) * 0.3),
        Paint()..color = Colors.white.withValues(alpha: 0.75 * oxy * (1 - ph)),
      );
    }
    canvas.restore();

    // Asa.
    canvas.drawPath(
      Path()
        ..moveTo(s * 0.5, -s * 0.28)
        ..cubicTo(s * 0.9, -s * 0.3, s * 0.85, s * 0.3, s * 0.4, s * 0.38),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.07
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF8E8A84),
    );
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = StudioColors.ink.withValues(alpha: 0.7),
    );

    // Vapor de la leche que se airea.
    if (!scene.pouring) {
      for (var i = 0; i < 2; i++) {
        final path = Path()..moveTo(-s * 0.15 + i * s * 0.3, -s * 0.4);
        for (var k = 1; k <= 5; k++) {
          path.lineTo(-s * 0.15 + i * s * 0.3 + math.sin(time * 3 + i + k) * s * 0.05, -s * 0.4 - k * s * 0.09);
        }
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 2.6
            ..color = Colors.white.withValues(alpha: 0.45)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4),
        );
      }
    }
  }
}
