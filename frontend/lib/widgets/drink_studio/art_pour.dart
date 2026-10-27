import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/cup_snapshot.dart';
import 'latte_pour_session.dart';
import 'studio_colors.dart';

/// Estado visual de la jarra en un instante (lo arma el escenario a
/// partir de [LattePourSession]).
class ArtScene {
  const ArtScene({
    this.jugShow = 0,
    this.lean = 0,
    this.target = Offset.zero,
    this.flow = 0,
    this.progress = 0,
  });

  /// 0..1: qué tan visible está la jarrita.
  final double jugShow;

  /// 0 = en reposo (a un lado) … 1 = inclinada sobre el punto de vertido.
  final double lean;

  /// Punto de vertido en coordenadas unitarias de la superficie.
  final Offset target;

  /// 0..1: intensidad del chorro.
  final double flow;

  /// Avance del relleno (la jarra se va vaciando).
  final double progress;
}

/// Dibujo del arte latte interactivo: crema de fondo, silueta guía,
/// leche vertida, jarra con su chorro y el festejo al terminar.
class ArtPour {
  ArtPour._();

  /// Mismo escalado con el que `SurfaceDecor.art` dibuja los diseños:
  /// el punto unitario (1, 0) cae a 0,8 del radio horizontal.
  static const double kx = 0.8;
  static const double ky = 0.86;

  static Offset _rot(Offset o, double a) => Offset(o.dx * math.cos(a) - o.dy * math.sin(a), o.dx * math.sin(a) + o.dy * math.cos(a));

  // ───────────── Superficie ─────────────

  /// Capa de crema (café tostado) sobre la que se vierte la leche. Con
  /// ella el diseño claro se lee bien incluso sobre una leche clara.
  static void crema(Canvas canvas, Offset c, double rx, double ry, Color base) {
    final rect = Rect.fromCenter(center: c, width: rx * 1.86, height: ry * 1.86);
    final tan = Color.lerp(base, const Color(0xFFC68A52), 0.5)!;
    canvas.drawOval(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [Color.lerp(tan, Colors.white, 0.08)!, Color.lerp(tan, base, 0.55)!],
          stops: const [0.4, 1],
        ).createShader(rect),
    );
  }

  /// Silueta guía + leche vertida hasta ahora. Se dibuja dentro de la
  /// boca del vaso (el escenario ya recortó a la elipse).
  static void paintLive(Canvas canvas, Offset c, double rx, double ry, LattePourSession s, {required bool guide}) {
    final sil = s.silhouette;
    if (sil == null) return;

    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(rx * kx, ry * ky);

    if (guide) {
      canvas.drawPath(sil, Paint()..color = StudioColors.cream.withValues(alpha: 0.14));
    }

    // Leche: manchas recortadas a la silueta (lo que cae fuera no la
    // ensucia, solo deja un pequeño derrame abajo).
    final milk = Paint()..color = StudioColors.cream.withValues(alpha: 0.97);
    canvas.save();
    canvas.clipPath(sil);
    for (final st in s.stamps) {
      canvas.drawCircle(Offset(st.x, st.y), st.r, milk);
    }
    canvas.restore();

    final spill = Paint()..color = StudioColors.cream.withValues(alpha: 0.4);
    for (final st in s.stamps) {
      if (!st.onTarget) canvas.drawCircle(Offset(st.x, st.y), st.r * 0.75, spill);
    }

    final dashes = s.guide;
    if (guide && dashes != null) {
      canvas.drawPath(
        dashes,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 0.035
          ..color = StudioColors.cream.withValues(alpha: 0.95),
      );
    }
    canvas.restore();
  }

  // ───────────── Jarra ─────────────

  /// Dibuja la jarrita y el chorro sobre la superficie ([c], [rx], [ry]).
  /// Con [ArtScene.lean] > 0 la jarra se desliza hasta quedar sobre el
  /// punto de vertido, con el pico apuntando hacia él.
  static void paint(Canvas canvas, Offset c, double rx, double ry, double jugSize, CupSnapshot snap, ArtScene scene, double time) {
    if (scene.jugShow <= 0) return;

    final lean = Curves.easeInOut.transform(scene.lean.clamp(0.0, 1.0).toDouble());
    final target = Offset(c.dx + scene.target.dx * rx * kx, c.dy + scene.target.dy * ry * ky);

    const tilt = -0.75;
    final angle = tilt * lean + (lean < 0.05 ? math.sin(time * 5) * 0.04 : 0.0); // vibra mientras airea
    final local = Offset(-jugSize * 0.62, -jugSize * 0.45);

    // Reposo a la derecha → sobre el punto de vertido (pico justo encima).
    final rest = Offset(c.dx + rx * 1.0, c.dy - ry * 1.9);
    final hoverSpout = target + Offset(jugSize * 0.04, -jugSize * 0.85);
    final hover = hoverSpout - _rot(local, tilt);
    final pos = Offset.lerp(rest, hover, lean)!;
    final spout = pos + _rot(local, angle);

    // El chorro va por debajo de la jarra.
    if (scene.flow > 0.02 && lean > 0.5) {
      _stream(canvas, spout, target, jugSize, scene.flow, time);
    }

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);
    canvas.saveLayer(null, Paint()..color = Colors.white.withValues(alpha: scene.jugShow.clamp(0.0, 1.0).toDouble() * (1 - 0.12 * lean)));
    _jug(canvas, jugSize, snap, scene, time);
    canvas.restore();
    canvas.restore();
  }

  /// Chorro de leche del pico al punto de vertido, con su salpicadura.
  static void _stream(Canvas canvas, Offset spout, Offset target, double jugSize, double flow, double time) {
    final path = Path()..moveTo(spout.dx, spout.dy);
    path.quadraticBezierTo(
      spout.dx - 2 + math.sin(time * 18) * 1.2,
      spout.dy + (target.dy - spout.dy) * 0.35,
      target.dx,
      target.dy,
    );
    final w = math.max(3.0, jugSize * 0.075) * flow;
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = w
        ..color = StudioColors.cream,
    );
    // Brillo del chorro.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = w * 0.3
        ..color = Colors.white.withValues(alpha: 0.75 * flow),
    );
    // Ondas donde cae la leche.
    for (var k = 0; k < 2; k++) {
      final p = (time * 1.8 + k * 0.5) % 1.0;
      final r = math.max(4.0, jugSize * 0.05) + jugSize * 0.2 * p;
      canvas.drawOval(
        Rect.fromCenter(center: target, width: r * 2, height: r * 2 * 0.6),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = Colors.white.withValues(alpha: 0.55 * (1 - p) * flow),
      );
    }
    canvas.drawCircle(target, math.max(3.4, jugSize * 0.055) * flow, Paint()..color = StudioColors.cream);
  }

  /// Jarrita de acero con leche (que baja al verter), burbujas y vapor.
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

    // Leche dentro: se va vaciando a medida que avanza el relleno.
    final milkTop = -s * 0.12 + s * 0.38 * scene.progress.clamp(0.0, 1.0);
    canvas.save();
    canvas.clipPath(body);
    canvas.drawRect(Rect.fromLTRB(-s, milkTop, s, s), Paint()..color = snap.milkColor);
    // Burbujas de aireación que suben (solo en reposo).
    final idle = (1 - scene.flow) * (1 - scene.lean);
    for (var i = 0; i < 6; i++) {
      final ph = (time * 0.9 + i * 0.37) % 1.0;
      canvas.drawCircle(
        Offset(-s * 0.25 + i * s * 0.1, s * 0.45 - ph * s * 0.55),
        s * 0.035 * (0.6 + (i % 3) * 0.3),
        Paint()..color = Colors.white.withValues(alpha: 0.75 * idle * (1 - ph)),
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

    // Vapor de la leche que se airea (solo en reposo).
    if (idle > 0.05) {
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
            ..color = Colors.white.withValues(alpha: 0.45 * idle)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4),
        );
      }
    }
  }

  // ───────────── Festejo ─────────────

  /// Brevísima animación de satisfacción al terminar el diseño: un
  /// anillo de brillo y destellos que salen de la superficie. [t] es
  /// el avance de la animación (0..1); fuera de ese rango no dibuja.
  static void celebrate(Canvas canvas, Offset c, double rx, double ry, double t) {
    if (t <= 0.15 || t >= 1) return;
    final p = (t - 0.15) / 0.85;
    final ease = Curves.easeOutCubic.transform(p);

    final grow = 0.95 + 0.3 * ease;
    canvas.drawOval(
      Rect.fromCenter(center: c, width: rx * 2 * grow, height: ry * 2 * grow),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2 * (1 - p) + 0.6
        ..color = Colors.white.withValues(alpha: 0.75 * (1 - p)),
    );

    const gold = Color(0xFFFFE9B0);
    const n = 10;
    for (var i = 0; i < n; i++) {
      final a = i / n * math.pi * 2 + (i.isEven ? 0.2 : -0.1);
      final dist = 0.55 + 0.8 * ease + (i % 3) * 0.08;
      final pos = Offset(c.dx + math.cos(a) * rx * dist, c.dy + math.sin(a) * ry * dist - ry * 0.3 * ease);
      final size = (4.0 + (i % 3) * 2.4) * math.sin(math.pi * p);
      _sparkle(canvas, pos, size, gold.withValues(alpha: (1 - p * p).clamp(0.0, 1.0).toDouble()));
    }
  }

  static void _sparkle(Canvas canvas, Offset p, double s, Color color) {
    if (s <= 0.2) return;
    final k = s * 0.28;
    canvas.drawPath(
      Path()
        ..moveTo(p.dx, p.dy - s)
        ..lineTo(p.dx + k, p.dy - k)
        ..lineTo(p.dx + s, p.dy)
        ..lineTo(p.dx + k, p.dy + k)
        ..lineTo(p.dx, p.dy + s)
        ..lineTo(p.dx - k, p.dy + k)
        ..lineTo(p.dx - s, p.dy)
        ..lineTo(p.dx - k, p.dy - k)
        ..close(),
      Paint()..color = color,
    );
  }
}
