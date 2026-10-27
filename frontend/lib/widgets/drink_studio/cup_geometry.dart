import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Medidas del vaso para un lienzo y un factor de tamaño dados. El
/// factor escala alto Y ancho a la vez (así crece la capacidad).
class CupGeo {
  /// [tilt] (0..1) sube y acerca la "cámara": la boca del vaso se abre
  /// más, la superficie de la bebida se ve con mayor perspectiva y el
  /// vaso crece (asomándose por abajo) para que en el arte latte la
  /// superficie sea lo bastante grande para verter con el dedo.
  CupGeo(Size size, double factor, {double tilt = 0}) {
    final unit = math.min(size.height, size.width * 1.35);
    cupH = unit * 0.5 * factor * (1 + 0.5 * tilt);
    topW = cupH * 0.66;
    botW = topW * 0.66;
    cx = size.width / 2;
    // Sin inclinación el vaso apoya en el 90 % del alto (como siempre);
    // con ella la boca sube hacia el centro del escenario.
    final restTop = size.height * 0.9 - unit * 0.5 * factor;
    topY = restTop + (size.height * 0.58 - restTop) * tilt;
    baseY = topY + cupH;
    rimRy = topW * (0.17 + 0.2 * tilt);
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

  /// Superficie de la bebida dentro de la boca: centro y radios. Cuanto
  /// más vacío el vaso ([fill] 0..1), más abajo y más pequeña se ve.
  /// La usan el painter y el gesto del vertido: así coinciden siempre.
  (Offset, double, double) surface(double fill) {
    final shrink = 1 - 0.14 * (1 - fill);
    return (Offset(cx, topY + (1 - fill) * rimRy * 0.9), rimRx * 0.97 * shrink, rimRy * 0.95 * shrink);
  }

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
