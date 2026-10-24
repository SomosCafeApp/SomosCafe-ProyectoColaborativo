import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'studio_colors.dart';

/// Ambiente de la bebida detrás y delante del vaso:
/// - Fría: escarcha que avanza desde los bordes de la pantalla.
/// - Caliente: resplandor cálido y ondas de calor que suben.
class AmbientPainter extends CustomPainter {
  AmbientPainter({required this.time, required this.cold, required this.front, required this.dark});

  final double time;

  /// 0 = caliente … 1 = fría (progresivo).
  final double cold;

  /// false = fondo (detrás del vaso); true = escarcha por delante.
  final bool front;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    if (front) {
      _frost(canvas, size);
    } else {
      _background(canvas, size);
      _heat(canvas, size);
    }
  }

  void _background(Canvas canvas, Size size) {
    final warm = 1 - cold;
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, 0.35),
          radius: 0.95,
          colors: [
            Color.lerp(
              dark ? const Color(0xFF3A2619) : StudioColors.beige,
              dark ? const Color(0xFF1D2C36) : const Color(0xFFDDEFF6),
              cold,
            )!,
            Colors.transparent,
          ],
        ).createShader(rect),
    );
    if (warm > 0) {
      canvas.drawCircle(
        Offset(size.width / 2, size.height * 0.55),
        size.width * 0.55,
        Paint()..color = const Color(0xFFFFB074).withValues(alpha: 0.12 * warm),
      );
    }
  }

  /// Ondas de calor: bandas sinuosas translúcidas que suben.
  void _heat(Canvas canvas, Size size) {
    final warm = 1 - cold;
    if (warm <= 0.02) return;
    for (var i = 0; i < 5; i++) {
      final phase = (time * 0.12 + i / 5) % 1.0;
      final y = size.height * (0.85 - phase * 0.75);
      final path = Path()..moveTo(0, y);
      for (var x = 0.0; x <= size.width; x += 8) {
        path.lineTo(x, y + math.sin(x * 0.045 + time * 2.2 + i) * 7 * (0.5 + phase));
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..color = const Color(0xFFFFB074).withValues(alpha: 0.10 * warm * (1 - phase))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }
  }

  /// Escarcha progresiva: franjas heladas en los bordes y cristales
  /// ramificados que crecen hacia el centro.
  void _frost(Canvas canvas, Size size) {
    if (cold <= 0.01) return;
    final depth = math.min(size.width, size.height) * 0.3 * cold;
    final ice = dark ? const Color(0xFFBFE3F2) : const Color(0xFFFFFFFF);

    void edge(Alignment from, Alignment to, Rect rect) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: from,
            end: to,
            colors: [ice.withValues(alpha: 0.7 * cold), const Color(0xFFBFE3F2).withValues(alpha: 0.25 * cold), Colors.transparent],
            stops: const [0, 0.45, 1],
          ).createShader(rect),
      );
    }

    edge(Alignment.topCenter, Alignment.bottomCenter, Rect.fromLTWH(0, 0, size.width, depth));
    edge(Alignment.bottomCenter, Alignment.topCenter, Rect.fromLTWH(0, size.height - depth, size.width, depth));
    edge(Alignment.centerLeft, Alignment.centerRight, Rect.fromLTWH(0, 0, depth, size.height));
    edge(Alignment.centerRight, Alignment.centerLeft, Rect.fromLTWH(size.width - depth, 0, depth, size.height));

    // Cristales: líneas con ramas que crecen según el progreso.
    final rnd = math.Random(9);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.3
      ..color = Colors.white.withValues(alpha: 0.75 * cold);
    for (var i = 0; i < 46; i++) {
      final side = i % 4;
      final t = rnd.nextDouble();
      final len = (10 + rnd.nextDouble() * 26) * cold;
      final origin = switch (side) {
        0 => Offset(size.width * t, 0),
        1 => Offset(size.width * t, size.height),
        2 => Offset(0, size.height * t),
        _ => Offset(size.width, size.height * t),
      };
      final dir = switch (side) {
        0 => const Offset(0, 1),
        1 => const Offset(0, -1),
        2 => const Offset(1, 0),
        _ => const Offset(-1, 0),
      };
      final tipPoint = origin + dir * len;
      canvas.drawLine(origin, tipPoint, paint);
      for (final k in [0.45, 0.75]) {
        final p = origin + dir * (len * k);
        final perp = Offset(-dir.dy, dir.dx);
        canvas.drawLine(p, p + (dir + perp) * len * 0.28, paint);
        canvas.drawLine(p, p + (dir - perp) * len * 0.28, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant AmbientPainter old) => true;
}
