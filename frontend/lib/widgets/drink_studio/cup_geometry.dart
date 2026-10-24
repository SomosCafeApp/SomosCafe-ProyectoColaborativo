import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Medidas del vaso para un lienzo y un factor de tamaño dados. El
/// factor escala alto Y ancho a la vez (así crece la capacidad).
class CupGeo {
  CupGeo(Size size, double factor) {
    final unit = math.min(size.height, size.width * 1.35);
    cupH = unit * 0.5 * factor;
    topW = cupH * 0.72;
    botW = topW * 0.70;
    cx = size.width / 2;
    baseY = size.height * 0.9;
    topY = baseY - cupH;
    rimRy = topW * 0.17;
  }

  late final double cupH, topW, botW, cx, baseY, topY, rimRy;

  double get rimRx => topW / 2;

  /// Medio ancho del vaso a la altura [y].
  double halfWidthAt(double y) {
    final t = ((baseY - y) / cupH).clamp(0.0, 1.0);
    return botW / 2 + (topW - botW) / 2 * t;
  }

  /// Contorno del cuerpo del vaso (cónico, base redondeada).
  Path body() => Path()
    ..moveTo(cx - topW / 2, topY)
    ..lineTo(cx + topW / 2, topY)
    ..lineTo(cx + botW / 2, baseY)
    ..quadraticBezierTo(cx, baseY + botW * 0.12, cx - botW / 2, baseY)
    ..close();

  Rect get rimRect => Rect.fromCenter(center: Offset(cx, topY), width: topW, height: rimRy * 2);

  /// Ventana por donde se ve el líquido (a la izquierda del logo).
  double get windowTop => topY + cupH * 0.12;
  double get windowBottom => baseY - cupH * 0.18;

  double windowLeft(double y) => cx - halfWidthAt(y) + topW * 0.07;
  double windowRight(double y) => windowLeft(y) + topW * 0.17;

  Path window() {
    const steps = 8;
    final path = Path();
    for (var i = 0; i <= steps; i++) {
      final y = windowTop + (windowBottom - windowTop) * i / steps;
      i == 0 ? path.moveTo(windowLeft(y), y) : path.lineTo(windowLeft(y), y);
    }
    for (var i = steps; i >= 0; i--) {
      final y = windowTop + (windowBottom - windowTop) * i / steps;
      path.lineTo(windowRight(y), y);
    }
    return path..close();
  }
}
