import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'studio_colors.dart';

/// Ambiente del estudio:
/// - Detrás: un fondo cálido y limpio (NUNCA azul).
/// - Delante: partículas pequeñas junto a los bordes de la pantalla.
///   Copos de nieve en bebidas frías; llamitas y soles en calientes.
///   Aparecen poco a poco y no cubren el centro ni los controles.
class AmbientPainter extends CustomPainter {
  AmbientPainter({required this.time, required this.cold, required this.front, required this.dark, this.strength = 1});

  final double time;

  /// 0 = caliente … 1 = fría (progresivo).
  final double cold;
  final bool front;
  final bool dark;

  /// 0..1: qué tan presentes están las partículas.
  final double strength;

  static const int _count = 30;

  @override
  void paint(Canvas canvas, Size size) {
    if (front) {
      _particles(canvas, size);
    } else {
      _background(canvas, size);
    }
  }

  void _background(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, 0.35),
          radius: 0.95,
          colors: [dark ? const Color(0xFF3A2619) : StudioColors.beige, Colors.transparent],
        ).createShader(rect),
    );
  }

  /// Posición base de la partícula [i] en una franja junto a un borde.
  Offset _anchor(int i, Size size, math.Random rnd) {
    final band = switch (i % 4) {
      0 => Rect.fromLTWH(0, 0, size.width * 0.16, size.height),
      1 => Rect.fromLTWH(size.width * 0.84, 0, size.width * 0.16, size.height),
      2 => Rect.fromLTWH(0, 0, size.width, size.height * 0.1),
      _ => Rect.fromLTWH(0, size.height * 0.92, size.width, size.height * 0.08),
    };
    return Offset(band.left + rnd.nextDouble() * band.width, band.top + rnd.nextDouble() * band.height);
  }

  void _particles(Canvas canvas, Size size) {
    final rnd = math.Random(17);
    for (var i = 0; i < _count; i++) {
      final anchor = _anchor(i, size, rnd);
      final speed = 0.5 + rnd.nextDouble();
      final phase = rnd.nextDouble() * math.pi * 2;
      final scale = 0.7 + rnd.nextDouble() * 0.9;
      final appear = i / _count;

      final coldA = ((cold * 1.25 - appear * 0.9) / 0.3).clamp(0.0, 1.0).toDouble() * strength;
      final warmA = (((1 - cold) * 1.25 - appear * 0.9) / 0.3).clamp(0.0, 1.0).toDouble() * strength;

      if (coldA > 0.01) {
        // Caen despacio con un vaivén suave.
        final y = (anchor.dy + time * speed * size.height * 0.05) % size.height;
        final x = anchor.dx + math.sin(time * 0.8 + phase) * 9;
        _snowflake(canvas, Offset(x, y), 3.2 * scale, coldA * 0.8, time * 0.3 + phase);
      }
      if (warmA > 0.01) {
        if (i % 5 == 0) {
          _sun(canvas, anchor, 4.6 * scale, warmA * 0.6, time * 0.5 + phase);
        } else {
          // Llamitas que suben y se desvanecen.
          final p = ((time * speed * 0.07) + phase / 6.3) % 1.0;
          final y = size.height - (anchor.dy + p * size.height * 0.5) % size.height;
          _flame(canvas, Offset(anchor.dx + math.sin(time * 2 + phase) * 4, y), 5.4 * scale, warmA * 0.7 * (1 - p * 0.5), time + phase);
        }
      }
    }
  }

  void _snowflake(Canvas canvas, Offset c, double r, double alpha, double rot) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.2
      ..color = (dark ? Colors.white : const Color(0xFF7FB6D1)).withValues(alpha: alpha);
    for (var k = 0; k < 3; k++) {
      final a = rot + k * math.pi / 3;
      final d = Offset(math.cos(a), math.sin(a)) * r;
      canvas.drawLine(c - d, c + d, paint);
    }
    canvas.drawCircle(c, r * 0.22, Paint()..color = Colors.white.withValues(alpha: alpha));
  }

  void _flame(Canvas canvas, Offset c, double r, double alpha, double t) {
    final flick = 1 + math.sin(t * 6) * 0.12;
    final path = Path()
      ..moveTo(c.dx, c.dy - r * 1.7 * flick)
      ..quadraticBezierTo(c.dx + r * 1.1, c.dy - r * 0.2, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx - r * 1.1, c.dy - r * 0.2, c.dx, c.dy - r * 1.7 * flick)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFF08A2E).withValues(alpha: alpha));
    canvas.drawCircle(c.translate(0, r * 0.25), r * 0.38, Paint()..color = const Color(0xFFFFD27A).withValues(alpha: alpha));
  }

  void _sun(Canvas canvas, Offset c, double r, double alpha, double rot) {
    final color = const Color(0xFFF6B73C).withValues(alpha: alpha);
    canvas.drawCircle(c, r, Paint()..color = color);
    final ray = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.3
      ..color = color;
    for (var k = 0; k < 8; k++) {
      final a = rot + k * math.pi / 4;
      canvas.drawLine(c + Offset(math.cos(a), math.sin(a)) * r * 1.5, c + Offset(math.cos(a), math.sin(a)) * r * 2.1, ray);
    }
  }

  @override
  bool shouldRepaint(covariant AmbientPainter old) => true;
}
