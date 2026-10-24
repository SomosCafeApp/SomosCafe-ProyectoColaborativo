import 'package:flutter/material.dart';

import 'studio_colors.dart';

/// Los tres diseños de latte art, dibujados en coordenadas unitarias
/// (x e y de -1 a 1, y hacia abajo). Quien los usa escala y posiciona.
class LatteArtShapes {
  LatteArtShapes._();

  static const List<String> designs = ['Corazón', 'Hoja', 'Cisne'];

  static void paint(Canvas c, String design, {double alpha = 1}) {
    final fill = Paint()..color = StudioColors.cream.withValues(alpha: alpha * 0.97);
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.04
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF8A5A36).withValues(alpha: alpha * 0.55);

    switch (design) {
      case 'Corazón':
        final heart = _heart();
        c.drawPath(heart, fill);
        c.drawPath(heart, edge);
        c.save();
        c.translate(0, 0.08);
        c.scale(0.52);
        c.drawPath(heart, edge);
        c.restore();
      case 'Hoja':
        for (var i = 0; i < 5; i++) {
          final y = 0.7 - i * 0.3;
          final w = 0.8 - i * 0.12;
          for (final s in [-1.0, 1.0]) {
            final leaf = Path()
              ..moveTo(0, y)
              ..quadraticBezierTo(s * w, y + 0.03, s * w * 0.9, y - 0.32)
              ..quadraticBezierTo(s * w * 0.22, y - 0.2, 0, y - 0.04)
              ..close();
            c.drawPath(leaf, fill);
            c.drawPath(leaf, edge);
          }
        }
        final tip = Path()
          ..moveTo(0, -0.7)
          ..quadraticBezierTo(0.2, -0.85, 0, -0.98)
          ..quadraticBezierTo(-0.2, -0.85, 0, -0.7);
        c.drawPath(tip, fill);
        c.drawLine(const Offset(0, 0.95), const Offset(0, -0.75), edge..strokeWidth = 0.05);
      case 'Cisne':
        final body = Path()
          ..moveTo(-0.88, 0.1)
          ..quadraticBezierTo(-0.6, 0.88, 0.1, 0.82)
          ..quadraticBezierTo(0.78, 0.76, 0.8, 0.22)
          ..quadraticBezierTo(0.42, 0.4, -0.1, 0.3)
          ..quadraticBezierTo(-0.5, 0.2, -0.88, 0.1)
          ..close();
        c.drawPath(body, fill);
        c.drawPath(body, edge);
        final neck = Path()
          ..moveTo(0.4, 0.38)
          ..cubicTo(0.98, 0.15, 0.72, -0.45, 0.42, -0.5)
          ..cubicTo(0.16, -0.55, 0.12, -0.8, 0.36, -0.84);
        c.drawPath(
          neck,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 0.24
            ..color = StudioColors.cream.withValues(alpha: alpha * 0.97),
        );
        c.drawCircle(const Offset(0.37, -0.84), 0.15, fill);
        c.drawPath(
          Path()
            ..moveTo(0.5, -0.88)
            ..lineTo(0.76, -0.8)
            ..lineTo(0.5, -0.75)
            ..close(),
          Paint()..color = StudioColors.caramel.withValues(alpha: alpha),
        );
        c.drawCircle(const Offset(0.41, -0.87), 0.026, Paint()..color = const Color(0xFF4A2C1B).withValues(alpha: alpha));
        for (var k = 0; k < 3; k++) {
          c.drawPath(
            Path()
              ..moveTo(-0.55 + k * 0.17, 0.5)
              ..quadraticBezierTo(-0.15 + k * 0.1, 0.2, 0.3, 0.5),
            edge..strokeWidth = 0.035,
          );
        }
    }
  }

  static Path _heart() => Path()
    ..moveTo(0, 0.82)
    ..cubicTo(-1.05, 0.15, -0.95, -0.85, -0.02, -0.32)
    ..cubicTo(0.95, -0.85, 1.05, 0.15, 0, 0.82)
    ..close();
}

/// Vista superior de una taza con el diseño: sirve de miniatura en las
/// tarjetas de selección y de ampliación del diseño elegido.
class LatteArtDisc extends StatelessWidget {
  const LatteArtDisc({super.key, required this.design, this.size = 72});
  final String design;
  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _DiscPainter(design));
}

class _DiscPainter extends CustomPainter {
  _DiscPainter(this.design);
  final String design;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final rect = Rect.fromCircle(center: Offset(r, r), radius: r);
    canvas.drawCircle(Offset(r, r), r, Paint()..color = StudioColors.latte);
    canvas.drawCircle(
      Offset(r, r),
      r * 0.86,
      Paint()..shader = const RadialGradient(colors: [Color(0xFF9A6A43), Color(0xFF4A2C1B)]).createShader(rect),
    );
    if (design.isEmpty) return;
    canvas.save();
    canvas.translate(r, r);
    canvas.scale(r * 0.66);
    LatteArtShapes.paint(canvas, design);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DiscPainter old) => old.design != design;
}
