import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Vapor que sube de la taza del logo.
class SteamPainter extends CustomPainter {
  SteamPainter({required this.time, required this.opacity});
  final double time;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    for (var i = 0; i < 3; i++) {
      final x0 = size.width / 2 + (i - 1) * 26;
      final path = Path()..moveTo(x0, size.height * 0.42);
      for (var k = 1; k <= 8; k++) {
        path.lineTo(x0 + math.sin(time * 1.5 + i * 1.8 + k * 0.75) * 5 * k / 3, size.height * 0.42 - k * 9);
      }
      final a = (0.2 + 0.2 * (0.5 + 0.5 * math.sin(time + i))) * opacity;
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 4
          ..color = AppColors.primary.withValues(alpha: a)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant SteamPainter old) => true;
}

/// Granos de café que flotan despacio por el fondo.
class FloatingBeansPainter extends CustomPainter {
  FloatingBeansPainter({required this.time, required this.dark});
  final double time;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(3);
    for (var i = 0; i < 14; i++) {
      final speed = 0.4 + rnd.nextDouble() * 0.6;
      final x = rnd.nextDouble() * size.width + math.sin((time + i) * math.pi * 2) * 10;
      final y = size.height - ((time * speed + rnd.nextDouble()) % 1.0) * (size.height + 40) + 20;
      final r = 6 + rnd.nextDouble() * 8;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(time * math.pi * 2 * speed + i);
      final color = (dark ? const Color(0xFFD9B88F) : AppColors.primary).withValues(alpha: 0.14);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 1.4, height: r * 2), Paint()..color = color);
      canvas.drawLine(Offset(0, -r * 0.9), Offset(0, r * 0.9), Paint()..strokeWidth = 1.4..color = color.withValues(alpha: 0.3));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant FloatingBeansPainter old) => true;
}
