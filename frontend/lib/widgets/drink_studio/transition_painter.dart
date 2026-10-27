import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/cup_snapshot.dart';

/// Detalles que acompañan el desplazamiento del vaso entre secciones:
/// - tempIntro: un copo y una llama (las dos temperaturas) que pasan.
/// - tempBurst: estallido breve de hielo o de fuego según la elección.
class TransitionPainter extends CustomPainter {
  TransitionPainter({required this.kind, required this.t, required this.cold, required this.time});

  final StudioTransition kind;

  /// 0..1: avance de la animación.
  final double t;
  final bool cold;
  final double time;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final fade = math.sin(t * math.pi).clamp(0.0, 1.0).toDouble();
    switch (kind) {
      case StudioTransition.tempIntro:
        _flake(canvas, Offset(size.width * (0.2 + 0.1 * t), size.height * (0.5 - 0.15 * t)), 15 + 6 * fade, fade);
        _flame(canvas, Offset(size.width * (0.8 - 0.1 * t), size.height * (0.5 - 0.15 * t)), 12 + 5 * fade, fade);
      case StudioTransition.tempBurst:
        _burst(canvas, Offset(size.width / 2, size.height * 0.5), size, fade);
      case StudioTransition.plain:
      case StudioTransition.none:
        break;
    }
  }

  void _flake(Canvas canvas, Offset c, double r, double a) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.4
      ..color = const Color(0xFF7FB6D1).withValues(alpha: a);
    for (var k = 0; k < 3; k++) {
      final ang = time + k * math.pi / 3;
      final d = Offset(math.cos(ang), math.sin(ang)) * r;
      canvas.drawLine(c - d, c + d, p);
    }
    canvas.drawCircle(c, r * 0.18, Paint()..color = Colors.white.withValues(alpha: a));
  }

  void _flame(Canvas canvas, Offset c, double r, double a) {
    final path = Path()
      ..moveTo(c.dx, c.dy - r * 1.7)
      ..quadraticBezierTo(c.dx + r * 1.1, c.dy - r * 0.2, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx - r * 1.1, c.dy - r * 0.2, c.dx, c.dy - r * 1.7)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFF08A2E).withValues(alpha: a));
    canvas.drawCircle(c.translate(0, r * 0.25), r * 0.4, Paint()..color = const Color(0xFFFFD27A).withValues(alpha: a));
  }

  void _burst(Canvas canvas, Offset c, Size size, double fade) {
    final reach = size.shortestSide * 0.42 * Curves.easeOutCubic.transform(t);
    for (var i = 0; i < 14; i++) {
      final a = i / 14 * math.pi * 2 + (i.isEven ? 0.1 : -0.1);
      final p = c + Offset(math.cos(a), math.sin(a)) * reach * (0.7 + (i % 3) * 0.15);
      if (cold) {
        // Cristalitos de hielo.
        final s = 5.0 + (i % 3) * 2;
        final path = Path()
          ..moveTo(p.dx, p.dy - s)
          ..lineTo(p.dx + s * 0.7, p.dy)
          ..lineTo(p.dx, p.dy + s)
          ..lineTo(p.dx - s * 0.7, p.dy)
          ..close();
        canvas.drawPath(path, Paint()..color = Colors.white.withValues(alpha: 0.85 * fade));
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2
            ..color = const Color(0xFF7FB6D1).withValues(alpha: fade),
        );
      } else {
        // Brasas y chispas.
        canvas.drawCircle(p, 2.6 + (i % 3), Paint()..color = (i.isEven ? const Color(0xFFF08A2E) : const Color(0xFFFFD27A)).withValues(alpha: 0.9 * fade));
      }
    }
  }

  @override
  bool shouldRepaint(covariant TransitionPainter old) => true;
}
