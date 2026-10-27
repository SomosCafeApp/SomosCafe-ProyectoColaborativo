
import 'package:flutter/material.dart';

import 'studio_colors.dart';

/// Los tres diseños de latte art, dibujados en coordenadas unitarias
/// (x e y de -1 a 1, y hacia abajo). Se construyen poco a poco con
/// `progress` (0..1), como si se estuvieran vertiendo.
class LatteArtShapes {
  LatteArtShapes._();

  static const List<String> designs = ['Corazón', 'Hoja', 'Cisne'];

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
    }
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
