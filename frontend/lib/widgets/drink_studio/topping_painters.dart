import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'studio_colors.dart';

/// Tipos de topping que el estudio sabe dibujar. El orden es el orden
/// de capas: primero lo que se espolvorea y por último lo que tiene
/// volumen.
enum ToppingKind { cocoa, cinnamon, cream, caramel, shavings, sprinkles, marshmallow, other }

/// Marco de la superficie de la bebida: centro y radios de la elipse
/// (en la vista desde arriba es un círculo) más la escala vertical con
/// la que hay que aplastar lo que va "tumbado" sobre ella.
class _Frame {
  _Frame(this.c, this.rx, this.ry, {required this.hasArt, required this.top}) : k = top ? 1.0 : math.max(0.18, math.min(1.0, ry / rx));

  final Offset c;
  final double rx;
  final double ry;
  final double k;
  final bool hasArt;
  final bool top;

  /// Punto de la superficie en coordenadas unitarias (-1..1).
  Offset at(double u, double v) => Offset(c.dx + rx * u, c.dy + ry * v);

  /// Punto aleatorio unitario. Con arte latte solo cae en la corona
  /// exterior para no tapar el diseño del centro.
  Offset unitSpot(math.Random r, {double reach = 0.9}) {
    final a = r.nextDouble() * math.pi * 2;
    final d = hasArt ? 0.66 + r.nextDouble() * (reach - 0.66) : math.sqrt(r.nextDouble()) * reach;
    return Offset(math.cos(a) * d, math.sin(a) * d);
  }

  /// Dibuja algo plano (aplastado en la vista de lado) centrado en [p].
  void flat(Canvas canvas, Offset p, double angle, void Function() draw) {
    canvas.save();
    canvas.translate(p.dx, p.dy);
    canvas.scale(1, k);
    canvas.rotate(angle);
    draw();
    canvas.restore();
  }
}

/// Dibujo de los toppings sobre la superficie de la bebida. Cada uno
/// crece con las porciones elegidas (más volumen, más piezas, más
/// hilos). Todo es determinista: la misma bebida se ve igual en cada
/// fotograma y al añadir porciones lo anterior no cambia de lugar.
class ToppingPainters {
  ToppingPainters._();

  static ToppingKind kindOf(String name) {
    final n = name.toLowerCase();
    if (n.contains('cacao') || n.contains('cocoa')) return ToppingKind.cocoa;
    if (n.contains('canela') || n.contains('cinn')) return ToppingKind.cinnamon;
    if (n.contains('crema') || n.contains('whip')) return ToppingKind.cream;
    if (n.contains('caramel')) return ToppingKind.caramel;
    if (n.contains('viruta') || n.contains('shaving')) return ToppingKind.shavings;
    if (n.contains('chispa') || n.contains('sprinkle')) return ToppingKind.sprinkles;
    if (n.contains('malva') || n.contains('marsh')) return ToppingKind.marshmallow;
    return ToppingKind.other;
  }

  static math.Random _rng(String name) => math.Random(name.codeUnits.fold<int>(17, (h, c) => (h * 31 + c) & 0xFFFFFF));

  static void paint(
    Canvas canvas,
    Offset c,
    double rx,
    double ry,
    List<String> names,
    Map<String, int> qty, {
    required bool hasArt,
    bool topView = false,
  }) {
    if (names.isEmpty || rx <= 1) return;
    final f = _Frame(c, rx, ry, hasArt: hasArt, top: topView);
    final ordered = [...names]..sort((a, b) => kindOf(a).index.compareTo(kindOf(b).index));
    for (final name in ordered) {
      final q = math.max(1, math.min(9, qty[name] ?? 1));
      final r = _rng(name);
      switch (kindOf(name)) {
        case ToppingKind.cocoa:
          _dust(canvas, f, r, q, const [Color(0xFF3B2416), Color(0xFF5A3522), Color(0xFF7A4A2E)], base: 120, perExtra: 70, haze: 0xFF4A2C1B, size: 0.8);
        case ToppingKind.cinnamon:
          _dust(canvas, f, r, q, const [Color(0xFF8A4B2A), Color(0xFFA0603A), Color(0xFF6B3A1F), Color(0xFFB87848)], base: 70, perExtra: 38, haze: 0xFF8A4B2A, size: 1.15);
        case ToppingKind.cream:
          if (hasArt) {
            _creamRing(canvas, f, q);
          } else if (topView) {
            _creamTop(canvas, f, q);
          } else {
            _creamSide(canvas, f, q);
          }
        case ToppingKind.caramel:
          _caramel(canvas, f, r, q);
        case ToppingKind.shavings:
          _shavings(canvas, f, r, q);
        case ToppingKind.sprinkles:
          _sprinkles(canvas, f, r, q);
        case ToppingKind.marshmallow:
          _marshmallows(canvas, f, r, q);
        case ToppingKind.other:
          _dust(canvas, f, r, q, const [StudioColors.latte, StudioColors.caramel], base: 40, perExtra: 20, haze: 0xFFD9B88F, size: 1.0);
      }
    }
  }

  // ───────────── Polvos: canela y cacao ─────────────

  static void _dust(Canvas canvas, _Frame f, math.Random r, int q, List<Color> tones, {required int base, required int perExtra, required int haze, required double size}) {
    final count = base + perExtra * (q - 1);

    // Velo suave debajo del polvo: da cuerpo y une los granos.
    final hazeAlpha = math.min(0.32, 0.1 + 0.05 * q);
    if (f.hasArt) {
      canvas.drawOval(
        Rect.fromCenter(center: f.c, width: f.rx * 2 * 0.92, height: f.ry * 2 * 0.92),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = f.rx * 0.2
          ..color = Color(haze).withValues(alpha: hazeAlpha * 0.6),
      );
    } else {
      canvas.drawOval(
        Rect.fromCenter(center: f.c, width: f.rx * 2 * 0.82, height: f.ry * 2 * 0.82),
        Paint()..color = Color(haze).withValues(alpha: hazeAlpha),
      );
    }

    final unit = f.rx / 95;
    for (var i = 0; i < count; i++) {
      final p = f.unitSpot(r, reach: 0.93);
      // Los granos sueltos se concentran más hacia el centro.
      final jitter = r.nextDouble();
      final tone = tones[(r.nextDouble() * tones.length).floor() % tones.length];
      final radius = (0.55 + jitter * 1.15) * size * unit * 1.25;
      canvas.drawCircle(f.at(p.dx, p.dy), math.max(0.5, radius), Paint()..color = tone.withValues(alpha: 0.5 + 0.45 * r.nextDouble()));
    }
  }

  // ───────────── Crema batida ─────────────

  /// Corona de rosetones alrededor del borde: el centro (el arte
  /// latte) queda libre.
  static void _creamRing(Canvas canvas, _Frame f, int q) {
    final n = math.min(22, 12 + 2 * (q - 1));
    final rr = f.rx * 0.105;
    final hh = f.top ? rr : math.max(rr * f.k * 1.5, rr * 0.55);
    final angles = [for (var i = 0; i < n; i++) i / n * math.pi * 2 + 0.2]..sort((a, b) => math.sin(a).compareTo(math.sin(b)));

    for (final a in angles) {
      final p = f.at(math.cos(a) * 0.87, math.sin(a) * 0.87);
      final lift = f.top ? 0.0 : hh * 0.35;
      final base = Rect.fromCenter(center: p.translate(0, -lift), width: rr * 2, height: hh * 2);

      canvas.drawOval(base.shift(Offset(rr * 0.12, hh * 0.35)), Paint()..color = Colors.black.withValues(alpha: 0.16));
      canvas.drawOval(
        base,
        Paint()..shader = const RadialGradient(center: Alignment(-0.3, -0.4), colors: [StudioColors.cream1, StudioColors.cream2, StudioColors.cream3], stops: [0, 0.55, 1]).createShader(base),
      );
      // Surcos del rosetón.
      final groove = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = math.max(0.8, rr * 0.1)
        ..color = StudioColors.cream4.withValues(alpha: 0.7);
      canvas.drawArc(base.deflate(rr * 0.28), -0.4, 3.4, false, groove);
      canvas.drawArc(base.deflate(rr * 0.58), 2.2, 3.4, false, groove);
      canvas.drawCircle(p.translate(-rr * 0.28, -lift - hh * 0.3), rr * 0.16, Paint()..color = Colors.white.withValues(alpha: 0.9));
    }
  }

  /// Desde arriba: un remolino de crema (manga pastelera en espiral).
  static void _creamTop(Canvas canvas, _Frame f, int q) {
    final radius = f.rx * math.min(0.74, 0.5 + 0.05 * (q - 1));
    final disc = Rect.fromCircle(center: f.c, radius: radius * 1.05);

    canvas.drawCircle(f.c.translate(radius * 0.05, radius * 0.07), radius * 1.05, Paint()..color = Colors.black.withValues(alpha: 0.18));
    canvas.drawCircle(
      f.c,
      radius * 1.05,
      Paint()..shader = const RadialGradient(colors: [StudioColors.cream2, StudioColors.cream3], stops: [0.4, 1]).createShader(disc),
    );

    final turns = 3.0 + 0.35 * (q - 1);
    const steps = 140;
    final path = Path();
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      final ang = t * turns * math.pi * 2;
      final rad = radius * (0.1 + 0.8 * t);
      final p = Offset(f.c.dx + math.cos(ang) * rad, f.c.dy + math.sin(ang) * rad);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    final tube = radius * 0.8 / turns * 1.12;

    Paint stroke(Color color, double w) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = w
      ..color = color;

    canvas.drawPath(path.shift(Offset(tube * 0.12, tube * 0.14)), stroke(StudioColors.cream4.withValues(alpha: 0.85), tube));
    canvas.drawPath(path, stroke(StudioColors.cream2, tube * 0.92));
    canvas.drawPath(path.shift(Offset(-tube * 0.14, -tube * 0.16)), stroke(Colors.white.withValues(alpha: 0.9), tube * 0.3));

    // Punta de la manga.
    canvas.drawCircle(f.c, radius * 0.13, Paint()..color = StudioColors.cream1);
    canvas.drawCircle(f.c.translate(-radius * 0.04, -radius * 0.05), radius * 0.05, Paint()..color = Colors.white);
  }

  /// De lado: un copete de crema en pisos con su remolino y su punta.
  static void _creamSide(Canvas canvas, _Frame f, int q) {
    final tiers = 3 + (q >= 3 ? 1 : 0) + (q >= 5 ? 1 : 0);
    final baseW = f.rx * 1.18 * (1 + 0.05 * (q - 1));
    final tierH = f.rx * 0.3;
    final baseY = f.c.dy + f.ry * 0.1;
    double topW = baseW;
    double topY = baseY;

    // Sombra sobre el líquido.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(f.c.dx, baseY + tierH * 0.15), width: baseW * 1.08, height: tierH * 0.8),
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );

    for (var t = 0; t < tiers; t++) {
      final w = baseW * (1 - 0.72 * t / tiers);
      final cy = baseY - t * tierH * 0.7;
      final rect = Rect.fromCenter(center: Offset(f.c.dx, cy), width: w, height: tierH);
      canvas.drawOval(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [StudioColors.cream1, StudioColors.cream2, StudioColors.cream3],
            stops: const [0, 0.55, 1],
          ).createShader(rect),
      );
      canvas.drawOval(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = StudioColors.cream4.withValues(alpha: 0.55),
      );
      // Surco en diagonal: da la sensación de espiral.
      canvas.drawPath(
        Path()
          ..moveTo(rect.left + w * 0.06, cy + tierH * 0.12)
          ..quadraticBezierTo(f.c.dx, cy + tierH * 0.55, rect.right - w * 0.06, cy - tierH * 0.12),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = math.max(1.0, tierH * 0.1)
          ..color = StudioColors.cream4.withValues(alpha: 0.6),
      );
      canvas.drawArc(
        rect.deflate(tierH * 0.18).translate(-w * 0.04, -tierH * 0.06),
        math.pi * 1.05,
        math.pi * 0.35,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = math.max(1.2, tierH * 0.1)
          ..color = Colors.white.withValues(alpha: 0.85),
      );
      topW = w;
      topY = cy;
    }

    // Punta rizada.
    final tip = Path()
      ..moveTo(f.c.dx - topW * 0.2, topY + tierH * 0.1)
      ..quadraticBezierTo(f.c.dx - topW * 0.06, topY - tierH * 0.25, f.c.dx + topW * 0.05, topY - tierH * 1.05)
      ..quadraticBezierTo(f.c.dx + topW * 0.24, topY - tierH * 0.3, f.c.dx + topW * 0.2, topY + tierH * 0.1)
      ..close();
    canvas.drawPath(tip, Paint()..color = StudioColors.cream1);
    canvas.drawPath(
      tip,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 1
        ..color = StudioColors.cream4.withValues(alpha: 0.7),
    );
    canvas.drawCircle(Offset(f.c.dx - topW * 0.05, topY - tierH * 0.3), math.max(1.2, tierH * 0.09), Paint()..color = Colors.white);
  }

  // ───────────── Caramelo ─────────────

  static void _caramel(Canvas canvas, _Frame f, math.Random r, int q) {
    final lines = <List<Offset>>[];
    final width = math.max(2.0, f.rx * 0.034);

    List<Offset> arc(double a0, double a1, double radius, double wobble, double phase) {
      final pts = <Offset>[];
      const n = 28;
      for (var i = 0; i <= n; i++) {
        final t = i / n;
        final a = a0 + (a1 - a0) * t;
        final d = radius + math.sin(t * math.pi * 5 + phase) * wobble;
        pts.add(f.at(math.cos(a) * d, math.sin(a) * d));
      }
      return pts;
    }

    if (f.hasArt) {
      // Hilo en la corona exterior, con huecos, sin tocar el diseño.
      final arcs = 2 + q;
      for (var i = 0; i < arcs; i++) {
        final start = r.nextDouble() * math.pi * 2;
        lines.add(arc(start, start + 0.9 + r.nextDouble() * 0.7, 0.8 + (i.isEven ? 0.04 : -0.03), 0.035, r.nextDouble() * 6));
      }
    } else {
      // Red de hilos que cruza la bebida, más densa con cada porción.
      final rows = 3 + q;
      for (var j = 0; j < rows; j++) {
        final v = -0.72 + 1.44 * j / (rows - 1);
        final half = math.sqrt(math.max(0.0, 0.9 * 0.9 - v * v));
        final pts = <Offset>[];
        const n = 30;
        for (var i = 0; i <= n; i++) {
          final t = i / n;
          final u = -half + 2 * half * t;
          pts.add(f.at(u, v + math.sin(t * math.pi * 3 + j * 1.7) * 0.07));
        }
        lines.add(pts);
      }
      if (q >= 3) {
        // Hilos cruzados.
        final cols = q - 1;
        for (var j = 0; j < cols; j++) {
          final u = -0.55 + 1.1 * j / math.max(1, cols - 1);
          final half = math.sqrt(math.max(0.0, 0.85 * 0.85 - u * u));
          final pts = <Offset>[];
          const n = 24;
          for (var i = 0; i <= n; i++) {
            final t = i / n;
            pts.add(f.at(u + math.sin(t * math.pi * 3 + j) * 0.07, -half + 2 * half * t));
          }
          lines.add(pts);
        }
      }
    }

    Path pathOf(List<Offset> pts, {Offset shift = Offset.zero}) {
      final path = Path()..moveTo(pts.first.dx + shift.dx, pts.first.dy + shift.dy);
      for (var i = 1; i < pts.length - 1; i++) {
        final mid = Offset((pts[i].dx + pts[i + 1].dx) / 2, (pts[i].dy + pts[i + 1].dy) / 2);
        path.quadraticBezierTo(pts[i].dx + shift.dx, pts[i].dy + shift.dy, mid.dx + shift.dx, mid.dy + shift.dy);
      }
      path.lineTo(pts.last.dx + shift.dx, pts.last.dy + shift.dy);
      return path;
    }

    Paint stroke(Color color, double w) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = w
      ..color = color;

    final clip = Path()..addOval(Rect.fromCenter(center: f.c, width: f.rx * 2 * 0.94, height: f.ry * 2 * 0.94));
    canvas.save();
    canvas.clipPath(clip);
    for (final pts in lines) {
      // Borde oscuro, cuerpo ámbar y brillo: un hilo brillante y espeso.
      canvas.drawPath(pathOf(pts), stroke(const Color(0xFF8C5420).withValues(alpha: 0.9), width * 1.35));
      canvas.drawPath(pathOf(pts), stroke(StudioColors.caramel, width));
      canvas.drawPath(pathOf(pts, shift: Offset(-width * 0.12, -width * 0.2 * f.k)), stroke(const Color(0xFFF6C77A).withValues(alpha: 0.9), width * 0.3));
    }
    canvas.restore();

    // Gotas al final de algunos hilos.
    for (var i = 0; i < lines.length; i++) {
      if (i % 2 == 1 && !f.hasArt) continue;
      final end = lines[i].last;
      canvas.drawOval(
        Rect.fromCenter(center: end, width: width * 1.9, height: math.max(width * 1.9 * f.k, width * 0.9)),
        Paint()..color = StudioColors.caramel,
      );
      canvas.drawCircle(end.translate(-width * 0.3, -width * 0.2 * f.k), width * 0.3, Paint()..color = const Color(0xFFF6C77A));
    }
  }

  // ───────────── Virutas de chocolate ─────────────

  static void _shavings(Canvas canvas, _Frame f, math.Random r, int q) {
    final n = 10 + 4 * (q - 1);
    final spots = _scatter(f, r, n, 0.16);
    final len = f.rx * 0.17;
    final thick = f.rx * 0.05;

    for (final u in spots) {
      final p = f.at(u.dx, u.dy);
      final angle = r.nextDouble() * math.pi;
      final shade = r.nextDouble();
      f.flat(canvas, p, angle, () {
        final rect = Rect.fromCenter(center: Offset.zero, width: len * (0.8 + 0.5 * shade), height: thick);
        final rr = RRect.fromRectAndRadius(rect, Radius.circular(thick * 0.5));
        canvas.drawRRect(rr.shift(Offset(thick * 0.15, thick * 0.3)), Paint()..color = Colors.black.withValues(alpha: 0.25));
        canvas.drawRRect(
          rr,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color.lerp(const Color(0xFF7A4A2E), const Color(0xFF3B2416), shade)!, const Color(0xFF2E1A10)],
            ).createShader(rect),
        );
        // Brillo del rizo y sección enrollada del extremo.
        canvas.drawLine(
          Offset(rect.left + thick * 0.5, rect.top + thick * 0.28),
          Offset(rect.right - thick * 0.9, rect.top + thick * 0.28),
          Paint()
            ..strokeCap = StrokeCap.round
            ..strokeWidth = math.max(0.8, thick * 0.18)
            ..color = const Color(0xFFC09A74).withValues(alpha: 0.85),
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(rect.right - thick * 0.45, 0), width: thick * 0.9, height: thick * 0.9),
          Paint()..color = const Color(0xFF5A3522),
        );
      });
    }
  }

  // ───────────── Chispas ─────────────

  static void _sprinkles(Canvas canvas, _Frame f, math.Random r, int q) {
    const palette = [Color(0xFF3B2416), Color(0xFFF3E2C3), Color(0xFFB5793F), Color(0xFFE4A0AC), Color(0xFFF2C94C), Color(0xFF8DB38B)];
    final n = 22 + 8 * (q - 1);
    final spots = _scatter(f, r, n, 0.12);
    final w = f.rx * 0.085;
    final h = f.rx * 0.036;

    for (var i = 0; i < spots.length; i++) {
      final p = f.at(spots[i].dx, spots[i].dy);
      final angle = r.nextDouble() * math.pi;
      final color = palette[i % palette.length];
      f.flat(canvas, p, angle, () {
        final rr = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: w, height: h), Radius.circular(h / 2));
        canvas.drawRRect(rr.shift(Offset(h * 0.2, h * 0.35)), Paint()..color = Colors.black.withValues(alpha: 0.2));
        canvas.drawRRect(rr, Paint()..color = color);
        canvas.drawLine(
          Offset(-w * 0.3, -h * 0.18),
          Offset(w * 0.28, -h * 0.18),
          Paint()
            ..strokeCap = StrokeCap.round
            ..strokeWidth = math.max(0.6, h * 0.22)
            ..color = Colors.white.withValues(alpha: 0.45),
        );
      });
    }
  }

  // ───────────── Malvaviscos ─────────────

  static void _marshmallows(Canvas canvas, _Frame f, math.Random r, int q) {
    final n = math.min(18, 4 + 3 * (q - 1));
    final spots = _scatter(f, r, n, f.hasArt ? 0.2 : 0.3)..sort((a, b) => a.dy.compareTo(b.dy));
    final size = f.rx * 0.13;

    for (var i = 0; i < spots.length; i++) {
      final p = f.at(spots[i].dx, spots[i].dy);
      final pink = i % 4 == 3;
      final top = pink ? const Color(0xFFFBE3E8) : const Color(0xFFFFFDF8);
      final side = pink ? const Color(0xFFF0C4CD) : const Color(0xFFE8DAC4);

      // Sombra proyectada sobre la bebida.
      canvas.drawOval(
        Rect.fromCenter(center: p.translate(size * 0.18, size * 0.28), width: size * 1.7, height: math.max(size * 1.7 * f.k, size * 0.6)),
        Paint()..color = Colors.black.withValues(alpha: 0.2),
      );

      if (f.top) {
        // Desde arriba: un cojincito redondeado con su centro más claro.
        final rect = Rect.fromCenter(center: p, width: size * 1.6, height: size * 1.6);
        final rr = RRect.fromRectAndRadius(rect, Radius.circular(size * 0.62));
        canvas.save();
        canvas.translate(p.dx, p.dy);
        canvas.rotate(i * 0.7);
        canvas.translate(-p.dx, -p.dy);
        canvas.drawRRect(rr, Paint()..shader = RadialGradient(colors: [top, side], stops: const [0.35, 1]).createShader(rect));
        canvas.drawRRect(
          rr,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.9
            ..color = side.withValues(alpha: 0.9),
        );
        canvas.drawCircle(p.translate(-size * 0.22, -size * 0.25), size * 0.2, Paint()..color = Colors.white.withValues(alpha: 0.9));
        canvas.restore();
      } else {
        // De lado: cilindro con su tapa elíptica.
        final bodyH = size * 1.15;
        final topH = math.max(size * 0.62, size * 1.5 * f.k);
        final body = RRect.fromRectAndRadius(
          Rect.fromCenter(center: p.translate(0, -bodyH * 0.1), width: size * 1.5, height: bodyH),
          Radius.circular(size * 0.45),
        );
        canvas.drawRRect(
          body,
          Paint()
            ..shader = LinearGradient(colors: [top, side], begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(body.outerRect),
        );
        final cap = Rect.fromCenter(center: Offset(p.dx, body.top + topH * 0.35), width: size * 1.5, height: topH);
        canvas.drawOval(cap, Paint()..color = top);
        canvas.drawOval(
          cap,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8
            ..color = side,
        );
        canvas.drawCircle(cap.center.translate(-size * 0.3, 0), size * 0.14, Paint()..color = Colors.white.withValues(alpha: 0.9));
      }
    }
  }

  // ───────────── Utilidades ─────────────

  /// Puntos unitarios repartidos sin amontonarse (distancia mínima
  /// [minDist]); con arte latte solo en la corona exterior.
  static List<Offset> _scatter(_Frame f, math.Random r, int n, double minDist) {
    final out = <Offset>[];
    var tries = 0;
    while (out.length < n && tries < n * 40) {
      tries++;
      final p = f.unitSpot(r, reach: 0.88);
      if (out.any((q) => (q - p).distance < minDist)) continue;
      out.add(p);
    }
    return out;
  }
}
