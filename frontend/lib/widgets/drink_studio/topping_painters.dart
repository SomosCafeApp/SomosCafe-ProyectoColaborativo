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

  /// Avance de la animación de entrada del topping que se está
  /// dibujando (0..1; 1 = ya asentado).
  double prog = 1;

  /// Altura desde la que caen las piezas (vista de lado).
  double get dropHeight => ry * 2.4 + rx * 0.8;

  /// Avance local de la pieza [i] de [n]: caen escalonadas, una tras otra.
  double piece(int i, int n, {double span = 0.45}) {
    if (prog >= 1) return 1;
    final start = n <= 1 ? 0.0 : (i / n) * (1 - span);
    return ((prog - start) / span).clamp(0.0, 1.0).toDouble();
  }

  /// Prepara el lienzo para una pieza que cae y rebota hasta asentarse
  /// (de lado cae desde arriba; desde arriba "se acerca" al crecer).
  /// Devuelve cuántos `save` hay que cerrar con [dropOut].
  int dropIn(Canvas canvas, Offset p, double lp) {
    if (lp >= 1) return 0;
    final e = 1 - Curves.bounceOut.transform(lp);
    final fade = (lp * 4).clamp(0.0, 1.0).toDouble();
    canvas.save();
    var saves = 1;
    if (top) {
      canvas.translate(p.dx, p.dy);
      canvas.scale(1 + e * 0.7);
      canvas.translate(-p.dx, -p.dy);
    } else {
      canvas.translate(0, -e * dropHeight);
    }
    if (fade < 1) {
      canvas.saveLayer(Rect.fromCircle(center: p, radius: rx * 0.45), Paint()..color = Colors.white.withValues(alpha: fade));
      saves++;
    }
    return saves;
  }

  void dropOut(Canvas canvas, int saves) {
    for (var i = 0; i < saves; i++) {
      canvas.restore();
    }
  }

  /// Crece desde el punto [p] con un pequeño rebote (rosetones, tiers).
  int popIn(Canvas canvas, Offset p, double lp) {
    if (lp >= 1) return 0;
    final k = Curves.easeOutBack.transform(lp).clamp(0.0, 1.2).toDouble();
    canvas.save();
    canvas.translate(p.dx, p.dy);
    canvas.scale(k);
    canvas.translate(-p.dx, -p.dy);
    return 1;
  }

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
    Map<String, double> progress = const {},
    double topMix = -1,
  }) {
    if (names.isEmpty || rx <= 1) return;
    // Durante el cambio de cámara, la vista de lado y la de arriba se
    // funden entre sí (sin salto).
    if (topMix > 0.001 && topMix < 0.999) {
      final bounds = Rect.fromCenter(center: c.translate(0, -rx * 0.6), width: rx * 3.2, height: rx * 3.2);
      canvas.saveLayer(bounds, Paint()..color = Colors.white.withValues(alpha: 1 - topMix));
      paint(canvas, c, rx, ry, names, qty, hasArt: hasArt, topView: false, progress: progress);
      canvas.restore();
      canvas.saveLayer(bounds, Paint()..color = Colors.white.withValues(alpha: topMix));
      paint(canvas, c, rx, ry, names, qty, hasArt: hasArt, topView: true, progress: progress);
      canvas.restore();
      return;
    }
    final f = _Frame(c, rx, ry, hasArt: hasArt, top: topMix >= 0.999 ? true : topView);
    final ordered = [...names]..sort((a, b) => kindOf(a).index.compareTo(kindOf(b).index));
    for (final name in ordered) {
      final q = math.max(1, math.min(9, qty[name] ?? 1));
      final r = _rng(name);
      f.prog = (progress[name] ?? 1.0).clamp(0.0, 1.0).toDouble();
      if (f.prog <= 0) continue;
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
    final hazeAlpha = math.min(0.32, 0.1 + 0.05 * q) * Curves.easeIn.transform(f.prog);
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
      final grainAlpha = 0.5 + 0.45 * r.nextDouble();
      // El polvo se espolvorea: cada grano cae desde arriba (o, desde
      // arriba de la taza, "se acerca") y se asienta en su sitio.
      final lp = f.piece(i, count, span: 0.55);
      if (lp <= 0) continue;
      final settle = Curves.easeIn.transform(lp);
      var at = f.at(p.dx, p.dy);
      var gr = radius;
      if (lp < 1) {
        if (f.top) {
          gr = radius * (1 + (1 - settle) * 0.9);
        } else {
          at = at.translate(math.sin(i * 1.7) * f.rx * 0.08 * (1 - settle), -(1 - settle) * f.dropHeight);
        }
      }
      canvas.drawCircle(at, math.max(0.5, gr), Paint()..color = tone.withValues(alpha: grainAlpha * (lp < 1 ? (lp * 3).clamp(0.0, 1.0) : 1)));
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

    var idx = 0;
    for (final a in angles) {
      final p = f.at(math.cos(a) * 0.87, math.sin(a) * 0.87);
      final lp = f.piece(idx++, n, span: 0.5);
      if (lp <= 0) continue;
      final saves = f.popIn(canvas, p, lp);
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
      f.dropOut(canvas, saves);
    }
  }

  /// Desde arriba: un remolino de crema (manga pastelera en espiral).
  static void _creamTop(Canvas canvas, _Frame f, int q) {
    final fullRadius = f.rx * math.min(0.74, 0.5 + 0.05 * (q - 1));
    // La crema sale en una espiral continua: el disco crece con ella.
    final radius = fullRadius * (0.45 + 0.55 * Curves.easeOut.transform(f.prog));
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

    // Tramo de espiral ya dibujado y posición de la punta de la manga.
    final metric = path.computeMetrics().first;
    final done = Curves.easeInOut.transform(f.prog);
    final drawn = f.prog >= 1 ? path : metric.extractPath(0, metric.length * done);
    final head = f.prog >= 1 ? f.c : (metric.getTangentForOffset(metric.length * done)?.position ?? f.c);

    Paint stroke(Color color, double w) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = w
      ..color = color;

    canvas.drawPath(drawn.shift(Offset(tube * 0.12, tube * 0.14)), stroke(StudioColors.cream4.withValues(alpha: 0.85), tube));
    canvas.drawPath(drawn, stroke(StudioColors.cream2, tube * 0.92));
    canvas.drawPath(drawn.shift(Offset(-tube * 0.14, -tube * 0.16)), stroke(Colors.white.withValues(alpha: 0.9), tube * 0.3));

    // Punta de la manga (mientras sale la crema sigue la espiral).
    canvas.drawCircle(head, radius * 0.13, Paint()..color = StudioColors.cream1);
    canvas.drawCircle(head.translate(-radius * 0.04, -radius * 0.05), radius * 0.05, Paint()..color = Colors.white);
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
      final tierLp = f.piece(t, tiers + 1, span: 0.5);
      if (tierLp <= 0) {
        topW = w;
        topY = cy;
        continue;
      }
      final tierSaves = f.popIn(canvas, Offset(f.c.dx, cy + tierH * 0.4), tierLp);
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
      f.dropOut(canvas, tierSaves);
      topW = w;
      topY = cy;
    }

    // Punta rizada (es lo último que sale).
    final tipLp = f.piece(tiers, tiers + 1, span: 0.5);
    if (tipLp <= 0) return;
    final tipSaves = f.popIn(canvas, Offset(f.c.dx, topY + tierH * 0.1), tipLp);
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
    f.dropOut(canvas, tipSaves);
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

    // Los hilos se dibujan uno tras otro, trazo a trazo: [lineT] es lo
    // que lleva dibujado el hilo [k] (0..1).
    double lineT(int k) => f.prog >= 1 ? 1.0 : (f.prog * lines.length - k).clamp(0.0, 1.0).toDouble();

    Path partOf(Path full, double t) {
      if (t >= 1) return full;
      final out = Path();
      for (final m in full.computeMetrics()) {
        out.addPath(m.extractPath(0, m.length * t), Offset.zero);
      }
      return out;
    }

    final clip = Path()..addOval(Rect.fromCenter(center: f.c, width: f.rx * 2 * 0.94, height: f.ry * 2 * 0.94));
    canvas.save();
    canvas.clipPath(clip);
    for (var k = 0; k < lines.length; k++) {
      final t = lineT(k);
      if (t <= 0) continue;
      final pts = lines[k];
      // Borde oscuro, cuerpo ámbar y brillo: un hilo brillante y espeso.
      canvas.drawPath(partOf(pathOf(pts), t), stroke(const Color(0xFF8C5420).withValues(alpha: 0.9), width * 1.35));
      canvas.drawPath(partOf(pathOf(pts), t), stroke(StudioColors.caramel, width));
      canvas.drawPath(partOf(pathOf(pts, shift: Offset(-width * 0.12, -width * 0.2 * f.k)), t), stroke(const Color(0xFFF6C77A).withValues(alpha: 0.9), width * 0.3));
      // Punta del chorro mientras el hilo se está trazando.
      if (t < 1) {
        final m = pathOf(pts).computeMetrics().first;
        final head = m.getTangentForOffset(m.length * t)?.position;
        if (head != null) canvas.drawCircle(head, width * 0.95, Paint()..color = StudioColors.caramel);
      }
    }
    canvas.restore();

    // Gotas al final de algunos hilos (cuando el hilo ya terminó).
    for (var i = 0; i < lines.length; i++) {
      if (lineT(i) < 1) continue;
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

    for (var i = 0; i < spots.length; i++) {
      final u = spots[i];
      final p = f.at(u.dx, u.dy);
      final angle = r.nextDouble() * math.pi;
      final shade = r.nextDouble();
      final lp = f.piece(i, spots.length);
      if (lp <= 0) continue;
      final saves = f.dropIn(canvas, p, lp);
      f.flat(canvas, p, angle + (1 - lp) * 2.4 * (i.isEven ? 1 : -1), () {
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
      f.dropOut(canvas, saves);
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
      final lp = f.piece(i, spots.length, span: 0.4);
      if (lp <= 0) continue;
      final saves = f.dropIn(canvas, p, lp);
      f.flat(canvas, p, angle + (1 - lp) * 3.0 * (i.isEven ? 1 : -1), () {
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
      f.dropOut(canvas, saves);
    }
  }

  // ───────────── Malvaviscos ─────────────

  static void _marshmallows(Canvas canvas, _Frame f, math.Random r, int q) {
    final n = math.min(18, 4 + 3 * (q - 1));
    final spots = _scatter(f, r, n, f.hasArt ? 0.2 : 0.3)..sort((a, b) => a.dy.compareTo(b.dy));
    final size = f.rx * 0.13;

    for (var i = 0; i < spots.length; i++) {
      final p = f.at(spots[i].dx, spots[i].dy);
      final lp = f.piece(i, spots.length, span: 0.5);
      if (lp <= 0) continue;
      final saves = f.dropIn(canvas, p, lp);
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
      f.dropOut(canvas, saves);
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
