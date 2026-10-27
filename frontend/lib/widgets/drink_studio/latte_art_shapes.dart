import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'studio_colors.dart';

/// Los tres diseños de latte art, dibujados en coordenadas unitarias
/// (x e y de -1 a 1, y hacia abajo). Se construyen poco a poco con
/// `progress` (0..1), como si se estuvieran vertiendo.
class LatteArtShapes {
  LatteArtShapes._();

  static const List<String> designs = ['Corazón', 'Hoja', 'Cisne', 'Tulipán', 'Rosetta', 'Estrella'];

  /// Silueta rellenable de [design] (la zona que hay que cubrir de
  /// leche al verter), o null si el diseño no tiene forma conocida.
  /// Se calcula una vez por diseño.
  static Path? silhouette(String design) {
    if (!designs.contains(design)) return null;
    return _silhouettes.putIfAbsent(design, () => _buildSilhouette(design));
  }

  static final Map<String, Path> _silhouettes = {};

  static Path _union(Iterable<Path> parts) {
    Path? acc;
    for (final p in parts) {
      acc = acc == null ? p : Path.combine(PathOperation.union, acc, p);
    }
    return acc ?? Path();
  }

  static Path _buildSilhouette(String design) {
    switch (design) {
      case 'Corazón':
        return Path.from(_heart);

      case 'Hoja':
        final parts = <Path>[];
        for (var i = 0; i < 5; i++) {
          final y = 0.7 - i * 0.3;
          final w = 0.8 - i * 0.12;
          for (final s in [-1.0, 1.0]) {
            parts.add(
              Path()
                ..moveTo(0, y)
                ..quadraticBezierTo(s * w, y + 0.03, s * w * 0.9, y - 0.32)
                ..quadraticBezierTo(s * w * 0.22, y - 0.2, 0, y - 0.04)
                ..close(),
            );
          }
        }
        // Tallo central y punta.
        parts.add(Path()..addRect(const Rect.fromLTRB(-0.06, -0.8, 0.06, 0.95)));
        parts.add(
          Path()
            ..moveTo(0, -0.7)
            ..quadraticBezierTo(0.2, -0.85, 0, -0.98)
            ..quadraticBezierTo(-0.2, -0.85, 0, -0.7)
            ..close(),
        );
        return _union(parts);

      case 'Cisne':
        // El cuello se dibuja con un trazo grueso: aquí se aproxima con
        // círculos a lo largo de su recorrido.
        final neck = Path();
        final m = _swanNeck.computeMetrics().first;
        for (var d = 0.0; d <= m.length; d += 0.05) {
          final t = m.getTangentForOffset(d);
          if (t != null) neck.addOval(Rect.fromCircle(center: t.position, radius: 0.12));
        }
        final head = Path()..addOval(Rect.fromCircle(center: const Offset(0.37, -0.84), radius: 0.15));
        return _union([Path.from(_swanBody), neck, head]);

      case 'Tulipán':
        return _union([for (final l in _tulipLayers) _tulipLayer(l), _tulipTip]);

      case 'Rosetta':
        return _union([
          for (var i = 0; i < _rosettaLayers; i++) _crescent(i),
          Path()..addRect(const Rect.fromLTRB(-0.06, -0.88, 0.06, 0.9)),
        ]);

      case 'Estrella':
        return _star(0.95, 0.42);
    }
    return Path();
  }

  static double _seg(double p, double from, double to) =>
      ((p - from) / (to - from)).clamp(0.0, 1.0).toDouble();

  /// Diseño terminado.
  static void paint(Canvas c, String design, {double alpha = 1}) =>
      paintProgress(c, design, 1, alpha: alpha);

  /// Punto unitario por donde la leche está cayendo en este momento.
  static Offset pourPoint(String design, double p) {
    switch (design) {
      case 'Corazón':
        return Offset(0.12 * (p * 9 % 2 - 1), 0.05 + 0.3 * (1 - p));

      case 'Hoja':
        return Offset(0, 0.85 - 1.55 * p);

      case 'Cisne':
        if (p < 0.35) {
          return Offset(-0.1 + 0.7 * p / 0.35, 0.55);
        }

        return Offset(
          0.45 - 0.1 * _seg(p, 0.35, 1),
          0.5 - 1.35 * _seg(p, 0.35, 1),
        );

      case 'Tulipán':
        return Offset(0, 0.6 - 1.5 * p);

      case 'Rosetta':
        return Offset(0, 0.85 - 1.6 * p);

      case 'Estrella':
        final a = -math.pi / 2 + 2 * math.pi * p;
        return Offset(0.7 * math.cos(a), 0.7 * math.sin(a));

      default:
        return Offset.zero;
    }
  }

  static void paintProgress(
    Canvas c,
    String design,
    double p, {
    double alpha = 1,
  }) {
    final fill = Paint()
      ..color = StudioColors.cream.withValues(alpha: alpha * 0.97);

    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.04
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF8A5A36).withValues(alpha: alpha * 0.55);

    switch (design) {
      case 'Corazón':
        final grow = Curves.easeOutCubic.transform(_seg(p, 0, 0.72));

        c.save();
        c.scale(grow);
        c.drawPath(_heart, fill);
        c.drawPath(_heart, edge);
        c.restore();

        final ring = _seg(p, 0.72, 1);

        if (ring > 0) {
          c.save();
          c.translate(0, 0.08);
          c.scale(0.52 * ring);
          c.drawPath(_heart, edge);
          c.restore();
        }

      case 'Hoja':
        for (var i = 0; i < 5; i++) {
          final t = Curves.easeOut.transform(
            _seg(p, i * 0.15, i * 0.15 + 0.24),
          );

          if (t <= 0) continue;

          final y = 0.7 - i * 0.3;
          final w = 0.8 - i * 0.12;

          for (final s in [-1.0, 1.0]) {
            c.save();
            c.translate(0, y);
            c.scale(t, 1);
            c.translate(0, -y);

            final leaf = Path()
              ..moveTo(0, y)
              ..quadraticBezierTo(s * w, y + 0.03, s * w * 0.9, y - 0.32)
              ..quadraticBezierTo(s * w * 0.22, y - 0.2, 0, y - 0.04)
              ..close();

            c.drawPath(leaf, fill);
            c.drawPath(leaf, edge);
            c.restore();
          }
        }

        final tipT = _seg(p, 0.85, 1);

        if (tipT > 0) {
          c.save();
          c.translate(0, -0.7);
          c.scale(tipT);
          c.translate(0, 0.7);

          c.drawPath(
            Path()
              ..moveTo(0, -0.7)
              ..quadraticBezierTo(0.2, -0.85, 0, -0.98)
              ..quadraticBezierTo(-0.2, -0.85, 0, -0.7),
            fill,
          );

          c.restore();
        }

        final stem = 1.7 * _seg(p, 0, 0.95);

        c.drawLine(
          const Offset(0, 0.95),
          Offset(0, 0.95 - stem),
          edge..strokeWidth = 0.05,
        );

      case 'Cisne':
        final bodyT = Curves.easeOutCubic.transform(
          _seg(p, 0, 0.35),
        );

        c.save();
        c.translate(0, 0.45);
        c.scale(bodyT);
        c.translate(0, -0.45);
        c.drawPath(_swanBody, fill);
        c.drawPath(_swanBody, edge);
        c.restore();

        final neckT = _seg(p, 0.3, 0.78);

        if (neckT > 0) {
          // Dart infiere el tipo PathMetric a partir de computeMetrics().
          final m = _swanNeck.computeMetrics().first;

          c.drawPath(
            m.extractPath(0, m.length * neckT),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round
              ..strokeWidth = 0.24
              ..color = StudioColors.cream.withValues(
                alpha: alpha * 0.97,
              ),
          );
        }

        final headT = Curves.easeOutBack.transform(
          _seg(p, 0.76, 1),
        );

        if (headT > 0) {
          c.save();
          c.translate(0.37, -0.84);
          c.scale(headT);

          c.drawCircle(Offset.zero, 0.15, fill);

          c.drawPath(
            Path()
              ..moveTo(0.13, -0.04)
              ..lineTo(0.39, 0.04)
              ..lineTo(0.13, 0.09)
              ..close(),
            Paint()
              ..color = StudioColors.caramel.withValues(alpha: alpha),
          );

          c.drawCircle(
            const Offset(0.04, -0.03),
            0.026,
            Paint()
              ..color = const Color(0xFF4A2C1B).withValues(alpha: alpha),
          );

          c.restore();
        }

        final wing = _seg(p, 0.5, 0.95);

        for (var k = 0; k < 3; k++) {
          c.drawPath(
            Path()
              ..moveTo(-0.55 + k * 0.17, 0.5)
              ..quadraticBezierTo(
                -0.15 + k * 0.1,
                0.2,
                0.3,
                0.5,
              ),
            edge
              ..strokeWidth = 0.035
              ..color = const Color(0xFF8A5A36).withValues(
                alpha: alpha * 0.55 * wing,
              ),
          );
        }

      case 'Tulipán':
        final tulipLine = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.035
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFF8A5A36).withValues(alpha: alpha * 0.55);

        for (var i = 0; i < _tulipLayers.length; i++) {
          final t = Curves.easeOut.transform(_seg(p, i * 0.24, i * 0.24 + 0.3));
          if (t <= 0) continue;
          final l = _tulipLayers[i];
          final path = _tulipLayer(l);
          c.save();
          c.translate(0, l.$2);
          c.scale(t, 1);
          c.translate(0, -l.$2);
          c.drawPath(path, fill);
          c.drawPath(path, tulipLine);
          c.restore();
        }

        final tip = Curves.easeOutBack.transform(_seg(p, 0.75, 1));
        if (tip > 0) {
          c.save();
          c.translate(0, -0.38);
          c.scale(tip);
          c.translate(0, 0.38);
          c.drawPath(_tulipTip, fill);
          c.drawPath(_tulipTip, tulipLine);
          c.restore();
        }

      case 'Rosetta':
        final rosettaLine = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.03
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFF8A5A36).withValues(alpha: alpha * 0.55);

        for (var i = 0; i < _rosettaLayers; i++) {
          final t = Curves.easeOut.transform(
            _seg(p, i / _rosettaLayers * 0.78, i / _rosettaLayers * 0.78 + 0.22),
          );
          if (t <= 0) continue;
          final y = _rosettaY(i);
          final path = _crescent(i);
          c.save();
          c.translate(0, y);
          c.scale(t, 1);
          c.translate(0, -y);
          c.drawPath(path, fill);
          c.drawPath(path, rosettaLine);
          c.restore();
        }

        final rosettaStem = 1.78 * _seg(p, 0, 0.95);
        c.drawLine(
          const Offset(0, 0.9),
          Offset(0, 0.9 - rosettaStem),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.07
            ..strokeCap = StrokeCap.round
            ..color = StudioColors.cream.withValues(alpha: alpha * 0.97),
        );

      case 'Estrella':
        final star = _star(0.95, 0.42);
        final reveal = _seg(p, 0, 0.85);

        c.save();
        if (reveal < 1) {
          // Las puntas aparecen girando alrededor del centro.
          c.clipPath(
            Path()
              ..moveTo(0, 0)
              ..arcTo(
                Rect.fromCircle(center: Offset.zero, radius: 2),
                -math.pi / 2,
                2 * math.pi * reveal,
                false,
              )
              ..close(),
          );
        }
        c.drawPath(star, fill);
        c.drawPath(star, edge);
        c.restore();

        final inner = _seg(p, 0.85, 1);
        if (inner > 0) {
          c.save();
          c.scale(0.5 * inner);
          c.drawPath(
            star,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.07
              ..strokeJoin = StrokeJoin.round
              ..color = const Color(0xFF8A5A36).withValues(alpha: alpha * 0.55),
          );
          c.restore();
        }
    }
  }

  // ───────────── Tulipán, Rosetta y Estrella ─────────────

  /// Capas del tulipán de abajo arriba: corazones apilados que se
  /// estrechan. (escala, y de la punta inferior).
  static const List<(double, double)> _tulipLayers = [
    (0.62, 0.9),
    (0.5, 0.5),
    (0.4, 0.1),
  ];

  /// Corazón de la misma forma que `_heart`, a escala [l].$1 y con su
  /// punta inferior en y = [l].$2.
  static Path _tulipLayer((double, double) l) {
    final k = l.$1;
    final dy = l.$2 - 0.82 * k;
    double x(double v) => v * k;
    double y(double v) => v * k + dy;
    return Path()
      ..moveTo(x(0), y(0.82))
      ..cubicTo(x(-1.05), y(0.15), x(-0.95), y(-0.85), x(-0.02), y(-0.32))
      ..cubicTo(x(0.95), y(-0.85), x(1.05), y(0.15), x(0), y(0.82))
      ..close();
  }

  static final Path _tulipTip = Path()
    ..moveTo(-0.17, -0.38)
    ..quadraticBezierTo(-0.12, -0.7, 0, -0.9)
    ..quadraticBezierTo(0.12, -0.7, 0.17, -0.38)
    ..close();

  static const int _rosettaLayers = 7;

  static double _rosettaY(int i) => 0.68 - i * 0.26;

  /// Arco ancho que cae hacia los lados (∩): cada capa del helecho.
  static Path _crescent(int i) {
    final y = _rosettaY(i);
    final w = 0.85 - i * 0.09;
    return Path()
      ..moveTo(-w, y + 0.12)
      ..quadraticBezierTo(0, y - 0.2, w, y + 0.12)
      ..lineTo(w * 0.9, y + 0.28)
      ..quadraticBezierTo(0, y, -w * 0.9, y + 0.28)
      ..close();
  }

  /// Estrella de [n] puntas centrada en el origen (una punta arriba).
  static Path _star(double outer, double inner, {int n = 5}) {
    final path = Path();
    for (var k = 0; k < n * 2; k++) {
      final r = k.isEven ? outer : inner;
      final a = -math.pi / 2 + k * math.pi / n;
      final x = r * math.cos(a), y = r * math.sin(a);
      k == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    return path..close();
  }

  static final Path _heart = Path()
    ..moveTo(0, 0.82)
    ..cubicTo(-1.05, 0.15, -0.95, -0.85, -0.02, -0.32)
    ..cubicTo(0.95, -0.85, 1.05, 0.15, 0, 0.82)
    ..close();

  static final Path _swanBody = Path()
    ..moveTo(-0.88, 0.1)
    ..quadraticBezierTo(-0.6, 0.88, 0.1, 0.82)
    ..quadraticBezierTo(0.78, 0.76, 0.8, 0.22)
    ..quadraticBezierTo(0.42, 0.4, -0.1, 0.3)
    ..quadraticBezierTo(-0.5, 0.2, -0.88, 0.1)
    ..close();

  static final Path _swanNeck = Path()
    ..moveTo(0.4, 0.38)
    ..cubicTo(0.98, 0.15, 0.72, -0.45, 0.42, -0.5)
    ..cubicTo(0.16, -0.55, 0.12, -0.8, 0.36, -0.84);
}

/// Vista superior de una taza con el diseño: miniatura de las tarjetas.
class LatteArtDisc extends StatelessWidget {
  const LatteArtDisc({
    super.key,
    required this.design,
    this.size = 72,
  });

  final String design;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _DiscPainter(design),
    );
  }
}

class _DiscPainter extends CustomPainter {
  _DiscPainter(this.design);

  final String design;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final rect = Rect.fromCircle(
      center: Offset(r, r),
      radius: r,
    );

    canvas.drawCircle(
      Offset(r, r),
      r,
      Paint()..color = StudioColors.latte,
    );

    canvas.drawCircle(
      Offset(r, r),
      r * 0.86,
      Paint()
        ..shader = const RadialGradient(
          colors: [
            Color(0xFF9A6A43),
            Color(0xFF4A2C1B),
          ],
        ).createShader(rect),
    );

    if (design.isEmpty) return;

    canvas.save();
    canvas.translate(r, r);
    canvas.scale(r * 0.66);
    LatteArtShapes.paint(canvas, design);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DiscPainter old) {
    return old.design != design;
  }
}
