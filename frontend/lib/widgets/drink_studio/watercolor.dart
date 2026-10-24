import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Pinceladas de "acuarela digital" sobre vectores: manchas suaves con
/// borde de pigmento, trazos a mano alzada y grano de papel.
class Watercolor {
  Watercolor._();

  /// Mancha de color: halo difuminado + relleno + borde más oscuro,
  /// como pigmento que se acumula en el borde del agua.
  static void wash(Canvas canvas, Path path, Color color, {double alpha = 0.6, double blur = 5}) {
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: alpha * 0.55)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
    );
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: alpha));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Color.lerp(color, Colors.black, 0.3)!.withValues(alpha: 0.28),
    );
  }

  /// Contorno a mano alzada: dos pasadas con un leve desfase.
  static void ink(Canvas canvas, Path path, Color color, {double width = 2.2}) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint..strokeWidth = width..color = color.withValues(alpha: 0.85));
    canvas.save();
    canvas.translate(0.9, -0.7);
    canvas.drawPath(path, paint..strokeWidth = width * 0.55..color = color.withValues(alpha: 0.35));
    canvas.restore();
  }

  /// Grano de papel: puntitos repartidos de forma determinista.
  static void grain(Canvas canvas, Size size, {int seed = 7, Color color = const Color(0xFF8A6A4A), int count = 160}) {
    final rnd = math.Random(seed);
    final paint = Paint();
    for (var i = 0; i < count; i++) {
      paint.color = color.withValues(alpha: 0.05 + rnd.nextDouble() * 0.07);
      canvas.drawCircle(
        Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height),
        0.5 + rnd.nextDouble() * 1.1,
        paint,
      );
    }
  }
}
