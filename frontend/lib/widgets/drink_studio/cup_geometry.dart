import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Medidas del vaso para un lienzo y un factor de tamaño dados. El
/// factor escala alto Y ancho a la vez (así crece la capacidad).
class CupGeo {
  /// Cámara virtual con dos parámetros continuos:
  ///  * [tilt] (0..1) sube y acerca la cámara: de la vista de lado a la
  ///    vista elevada del arte latte (la boca se abre, el vaso crece).
  ///  * [top] (0..1) sigue hasta la vista cenital: la boca se vuelve un
  ///    círculo en el centro del escenario y el cuerpo del vaso se
  ///    esconde tras el borde, como en una toma desde arriba.
  /// Todo es geometría continua del MISMO vaso: no hay cambio de
  /// componente ni salto, solo una cámara que se acerca y se inclina.
  CupGeo(Size size, double factor, {this.tilt = 0, this.top = 0, bool packets = false}) {
    final unit = math.min(size.height, size.width * 1.35);
    final cupH0 = unit * 0.5 * factor * (1 + 0.5 * tilt);
    final topW0 = cupH0 * 0.66;
    // Sin inclinación el vaso apoya en el 90 % del alto (como siempre);
    // con ella la boca sube hacia el centro del escenario.
    final restTop = size.height * 0.9 - unit * 0.5 * factor;
    final topY0 = restTop + (size.height * 0.58 - restTop) * tilt;
    final rimRy0 = topW0 * (0.17 + 0.25 * tilt);

    // Destino cenital: círculo centrado (con sobres de endulzante la taza
    // se corre un poco para dejarles sitio).
    final side = math.min(size.width, size.height);
    final r = side / 2 * 0.86 * (packets ? 0.84 : 1.0) * (0.9 + 0.1 * (factor / 1.14).clamp(0.7, 1.0).toDouble());
    final center = packets ? Offset(size.width * 0.46, size.height * 0.46) : Offset(size.width / 2, size.height / 2);

    final k = top;
    topW = _lerp(topW0, r * 2, k);
    cx = _lerp(size.width / 2, center.dx, k);
    topY = _lerp(topY0, center.dy, k);
    // El cuerpo se esconde detrás del borde al mirar desde arriba.
    cupH = cupH0 * (1 - 0.94 * k);
    botW = topW * (0.66 + 0.3 * k);
    baseY = topY + cupH;
    rimRy = _lerp(rimRy0, topW / 2, k);
    _cupH0 = cupH0;
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  /// Acercamiento de la cámara (0..1).
  final double tilt;

  /// Cuánto ha llegado a la vista cenital (0..1).
  final double top;

  late final double cupH, topW, botW, cx, baseY, topY, rimRy, _cupH0;

  /// Alto del vaso en la vista inclinada (sin aplastar por la vista
  /// cenital); sirve para medidas que no deben cambiar con [top].
  double get fullCupH => _cupH0;

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
  /// Superficie tal como se ve: al acercar la cámara para el arte latte
  /// el café se muestra siempre casi a ras del borde, para que el diseño
  /// quede grande, centrado y completo aunque la taza lleve poca leche.
  (Offset, double, double) visibleSurface(double fill) {
    final tilted = surface(fill + (math.max(fill, 0.88) - fill) * tilt);
    if (top <= 0) return tilted;
    // Vista cenital: la superficie es un círculo algo menor que la boca
    // (queda visible el grosor del borde del vaso).
    final r = rimRx * (0.8 - 0.06 * (1 - math.max(fill, 0.88)));
    final c = Offset(cx, topY);
    return (
      Offset.lerp(tilted.$1, c, top)!,
      _lerp(tilted.$2, r, top),
      _lerp(tilted.$3, r, top),
    );
  }

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
