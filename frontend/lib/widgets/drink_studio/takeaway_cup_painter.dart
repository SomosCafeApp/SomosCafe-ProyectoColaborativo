import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/cup_snapshot.dart';
import 'ambient_painter.dart';
import 'art_pour.dart';
import 'cup_geometry.dart';
import 'latte_pour_session.dart';
import 'studio_colors.dart';
import 'surface_decor.dart';
import 'sweetener_packet.dart';
import 'watercolor.dart';

/// Vaso de cafetería para llevar con la marca Somos Café: franja
/// café, logo, ventana que muestra el líquido con marcas de capacidad,
/// boca abierta con la superficie de la bebida y, al terminar, tapa
/// (con pitillo si es fría). Estilo vectorial con textura acuarela.
class TakeawayCupPainter extends CustomPainter {
  TakeawayCupPainter({
    required this.snap,
    required this.time,
    required this.cold,
    required this.effect,
    required this.effectT,
    required this.effectSeed,
    required this.scene,
    required this.lid,
    required this.dark,
    this.pour,
    this.artSettle = 1,
    this.celebrate = 1,
    this.tilt = 0,
    this.top = 0,
    this.quality = 1,
    this.toppingProgress = const {},
  });

  final CupSnapshot snap;
  final double time;

  /// 0 = caliente … 1 = fría (transición animada).
  final double cold;
  final PourKind effect;
  final double effectT;
  final int effectSeed;
  final ArtScene scene;

  /// Vertido interactivo del arte latte (silueta guía, leche vertida).
  /// Null fuera de la etapa de arte (resumen, miniaturas).
  final LattePourSession? pour;

  /// 0..1: fundido de la leche vertida al diseño terminado.
  final double artSettle;

  /// 0..1: avance del festejo al terminar el diseño (1 = ya pasó).
  final double celebrate;

  /// 0 = vista de lado … 1 = vista más cenital (sección de arte latte).
  final double tilt;

  /// 0 = vista inclinada … 1 = vista cenital (la cámara sigue subiendo:
  /// el cuerpo del vaso se esconde tras el borde y aparece el plato).
  final double top;

  /// 0.5 (dispositivo modesto) … 1: cantidad y calidad de los efectos.
  final double quality;

  /// Avance (0..1) de la animación de entrada de cada topping recién añadido.
  final Map<String, double> toppingProgress;

  /// 0 = sin tapa … 1 = tapa puesta.
  final double lid;
  final bool dark;

  static const Color _paper = Color(0xFFFFFAF0);

  /// Centro y radios de la superficie (se calculan en _opening).
  (Offset, double, double)? _surface;

  @override
  void paint(Canvas canvas, Size size) {
    final g = CupGeo(size, snap.sizeFactor, tilt: tilt, top: top, packets: snap.sweeteners.isNotEmpty);

    // Vista cenital: el plato aparece bajo el vaso.
    if (top > 0.01) _plate(canvas, g);

    // El cuerpo del vaso (franja, ventana, logo...) se desvanece mientras
    // la cámara sube; el borde y la bebida siguen siendo los mismos.
    final bodyA = (1 - top * 1.6).clamp(0.0, 1.0).toDouble();
    if (bodyA > 0.01) {
      final fade = bodyA < 1;
      if (fade) canvas.saveLayer(null, Paint()..color = Colors.white.withValues(alpha: bodyA));
      _shadow(canvas, g);
      _body(canvas, g);
      _window(canvas, g);
      _brand(canvas, g);
      _nameLabel(canvas, g);
      _condensation(canvas, g);
      if (fade) canvas.restore();
    }
    _opening(canvas, g);
    if (lid < 1) _steam(canvas, g);
    _lid(canvas, g);
    _lidSteam(canvas, g);
    _packets(canvas, g, size);
    _jug(canvas, g);
    _celebrate(canvas);

    Watercolor.grain(canvas, size);
  }

  // ───────────── Sobres de endulzante ─────────────

  /// Cada endulzante elegido es un sobre individual apoyado junto a la
  /// base del vaso (se esconde al acercar la cámara para el arte latte).
  void _packets(Canvas canvas, CupGeo g, Size size) {
    final names = snap.sweeteners;
    if (names.isNotEmpty && top > 0.01) _packetsTop(canvas, g, size);
    final visible = (1 - tilt * 2.5).clamp(0.0, 1.0).toDouble() * (1 - top);
    if (names.isEmpty || visible <= 0) return;

    final free = size.width - (g.cx + g.botW / 2) - 6;
    final n = names.length;
    final w = math.min(g.topW * 0.27, free / (0.9 + 0.62 * (n - 1) + 0.2)).clamp(14.0, 60.0).toDouble();
    if (w <= 14.5 && free < 30) return;
    final h = w * SweetenerPacketPainter.aspect;

    if (visible < 1) canvas.saveLayer(null, Paint()..color = Colors.white.withValues(alpha: visible));
    for (var i = n - 1; i >= 0; i--) {
      final center = Offset(g.cx + g.botW / 2 + w * 0.75 + i * w * 0.62, g.baseY - h * 0.42 - i * w * 0.05);
      SweetenerPacketPainter.paint(canvas, center, w, names[i], angle: 0.2 - i * 0.14);
    }
    if (visible < 1) canvas.restore();
  }

  /// Vista cenital: los sobres quedan apoyados junto al plato.
  void _packetsTop(Canvas canvas, CupGeo g, Size size) {
    final names = snap.sweeteners;
    final n = names.length;
    final w = math.min(g.topW / 2 * 0.36, size.width * 0.13);
    final h = w * SweetenerPacketPainter.aspect;
    canvas.saveLayer(null, Paint()..color = Colors.white.withValues(alpha: top));
    for (var i = n - 1; i >= 0; i--) {
      final center = Offset(size.width - w * 0.85 - i * w * 0.5, size.height - h * 0.62 - i * w * 0.05);
      SweetenerPacketPainter.paint(canvas, center, w, names[i], angle: -0.22 + i * 0.16);
    }
    canvas.restore();
  }

  // ───────────── Plato (vista cenital) ─────────────

  void _plate(Canvas canvas, CupGeo g) {
    final c = Offset(g.cx, g.topY);
    final r = g.topW / 2;
    final bounds = Rect.fromCircle(center: c, radius: r * 1.4);
    canvas.saveLayer(bounds, Paint()..color = Colors.white.withValues(alpha: top.clamp(0.0, 1.0).toDouble()));
    // Sombra suave del plato sobre la mesa (la luz viene de arriba a la izquierda).
    canvas.drawCircle(
      c.translate(r * 0.05, r * 0.1),
      r * 1.16,
      Paint()
        ..color = Colors.black.withValues(alpha: dark ? 0.35 : 0.16)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, quality >= 0.75 ? 10 : 5),
    );
    Watercolor.wash(canvas, Path()..addOval(Rect.fromCircle(center: c, radius: r * 1.14)), StudioColors.latte, alpha: dark ? 0.55 : 0.8, blur: 4);
    canvas.drawCircle(
      c,
      r * 1.04,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = StudioColors.ink.withValues(alpha: 0.25),
    );
    // Sombra que proyecta el vaso sobre el plato (abajo a la derecha).
    canvas.drawCircle(
      c.translate(r * 0.1, r * 0.14),
      r * 1.02,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.restore();
  }

  // ───────────── Cuerpo ─────────────

  void _shadow(Canvas canvas, CupGeo g) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(g.cx, g.baseY + g.botW * 0.1), width: g.topW * 1.15, height: g.topW * 0.18),
      Paint()
        ..color = Colors.black.withValues(alpha: dark ? 0.35 : 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  void _body(Canvas canvas, CupGeo g) {
    final body = g.body();
    final rect = Rect.fromLTRB(g.cx - g.topW / 2, g.topY, g.cx + g.topW / 2, g.baseY);
    // Resplandor de temperatura por detrás del vaso (no sobre él).
    if (quality >= 0.75) {
      ThermalOutline.stroke(canvas, body, body.getBounds(), cold: cold, time: time, width: 2.4, dark: dark, crisp: false);
    }
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          colors: [_paper, Color.lerp(_paper, const Color(0xFFD9C3A3), 0.45)!],
        ).createShader(rect),
    );

    // Vaso frío: plástico con un leve tinte azulado.
    if (cold > 0) canvas.drawPath(body, Paint()..color = const Color(0xFFBFE3F2).withValues(alpha: 0.12 * cold));

    // Franja inferior de la marca con las onzas.
    canvas.save();
    canvas.clipPath(body);
    final bandTop = g.baseY - g.cupH * 0.15;
    canvas.drawRect(Rect.fromLTRB(g.cx - g.topW, bandTop, g.cx + g.topW, g.baseY + 30), Paint()..color = AppColors.primary);
    canvas.drawRect(Rect.fromLTRB(g.cx - g.topW, bandTop, g.cx + g.topW, bandTop + 2.2), Paint()..color = StudioColors.cream.withValues(alpha: 0.7));

    // Sombra en el costado derecho y un brillo vertical: el vaso gana volumen.
    final round = Rect.fromLTRB(g.cx - g.topW * 0.55, g.topY, g.cx + g.topW * 0.55, g.baseY);
    canvas.drawRect(
      round,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.black.withValues(alpha: dark ? 0.2 : 0.1),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: dark ? 0.3 : 0.18),
          ],
          stops: const [0, 0.22, 0.62, 1],
        ).createShader(round),
    );
    // Costura vertical del vaso (sigue la inclinación del cono).
    canvas.drawLine(
      Offset(g.cx + g.halfWidthAt(g.topY) * 0.8, g.topY),
      Offset(g.cx + g.halfWidthAt(g.baseY) * 0.8, g.baseY),
      Paint()
        ..strokeWidth = 1
        ..color = Colors.black.withValues(alpha: 0.07),
    );
    final gloss = Rect.fromLTRB(g.cx + g.topW * 0.30, g.topY + g.cupH * 0.04, g.cx + g.topW * 0.40, bandTop - g.cupH * 0.03);
    canvas.drawRRect(
      RRect.fromRectAndRadius(gloss, Radius.circular(g.topW * 0.05)),
      Paint()..color = Colors.white.withValues(alpha: 0.28),
    );
    canvas.restore();

    final oz = snap.ounces;
    if (oz != null) {
      _text(canvas, '$oz OZ', Offset(g.cx, g.baseY - g.cupH * 0.075), g.topW * 0.09, StudioColors.cream, spacing: 1.6);
    }

    Watercolor.ink(canvas, body, StudioColors.ink, width: 2.4);
    // Contorno degradado: cálido (crema, ámbar, terracota) o frío (hielo,
    // turquesa, azul), siguiendo la luz del vaso.
    ThermalOutline.stroke(canvas, body, body.getBounds(), cold: cold, time: time, width: 2.0, intensity: 0.85, glow: false, dark: dark);
  }

  void _text(Canvas canvas, String text, Offset center, double size, Color color, {double spacing = 0, FontWeight weight = FontWeight.w800}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: size, fontWeight: weight, letterSpacing: spacing)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  // ───────────── Ventana con el líquido ─────────────

  void _window(Canvas canvas, CupGeo g) {
    final win = g.window();
    final top = g.windowTop, bottom = g.windowBottom, h = bottom - top;
    final left = g.windowLeft(top) - 4, right = g.windowRight(bottom) + 4;

    canvas.save();
    canvas.clipPath(win);
    canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), Paint()..color = const Color(0xFFEADCC6));

    final baseFrac = snap.isCoffee ? math.min(0.16 + 0.055 * snap.shots, 0.46) : 0.5;
    final milkFrac = math.max(0.0, math.min(snap.milkLevel * 0.62, 0.9 - baseFrac));
    final yBase = bottom - h * baseFrac;
    final yTop = bottom - h * (baseFrac + milkFrac);
    final lower = snap.baseColor;
    final upper = snap.milkColor;

    final low = Rect.fromLTRB(left, yBase, right, bottom);
    canvas.drawRect(
      low,
      Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [lower, Color.lerp(lower, Colors.black, 0.25)!]).createShader(low),
    );

    if (milkFrac > 0.01) {
      final wave = Path()..moveTo(left, yBase);
      for (var x = left; x <= right; x += 3) {
        wave.lineTo(x, yBase + math.sin(time * 1.8 + x * 0.25) * 1.4);
      }
      wave..lineTo(right, yTop)..lineTo(left, yTop)..close();
      canvas.drawPath(wave, Paint()..color = upper.withValues(alpha: 0.97));
      // Capa de espuma en lo alto de la leche.
      canvas.drawRect(Rect.fromLTRB(left, yTop, right, yTop + h * 0.04), Paint()..color = Color.lerp(upper, Colors.white, 0.55)!.withValues(alpha: 0.9));

    }

    // Hielo en bebidas frías (aparece con la transición de temperatura).
    if (cold > 0) {
      for (var i = 0; i < 3; i++) {
        final cy = yTop + h * 0.07 + i * h * 0.1 + math.sin(time * 1.4 + i) * 1.4;
        final cx = (left + right) / 2 + (i - 1) * (right - left) * 0.12;
        canvas.save();
        canvas.translate(cx, cy);
        canvas.rotate(0.3 + i * 0.5);
        final r = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: h * 0.12, height: h * 0.12), const Radius.circular(3));
        canvas.drawRRect(r, Paint()..color = Colors.white.withValues(alpha: 0.4 * cold));
        canvas.drawRRect(
          r,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2
            ..color = Colors.white.withValues(alpha: 0.85 * cold),
        );
        canvas.restore();
      }
    }
    canvas.restore();

    // Marcas de capacidad y borde de la ventana.
    final tick = Paint()
      ..strokeWidth = 1.4
      ..color = StudioColors.ink.withValues(alpha: 0.55);
    for (final f in [0.25, 0.5, 0.75]) {
      final y = bottom - h * f;
      canvas.drawLine(Offset(g.windowRight(y) - g.topW * 0.045, y), Offset(g.windowRight(y), y), tick);
    }
    Watercolor.ink(canvas, win, StudioColors.ink, width: 1.8);
  }

  // ───────────── Marca ─────────────

  void _brand(Canvas canvas, CupGeo g) {
    final c = Offset(g.cx + g.topW * 0.13, g.topY + g.cupH * 0.38);
    final r = g.topW * 0.15;
    canvas.drawCircle(c, r, Paint()..color = StudioColors.cream);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = AppColors.primary,
    );
    // Taza con vapor dentro del logo.
    final cup = Path()
      ..moveTo(c.dx - r * 0.42, c.dy - r * 0.05)
      ..lineTo(c.dx + r * 0.42, c.dy - r * 0.05)
      ..lineTo(c.dx + r * 0.3, c.dy + r * 0.5)
      ..lineTo(c.dx - r * 0.3, c.dy + r * 0.5)
      ..close();
    canvas.drawPath(cup, Paint()..color = AppColors.primary);
    final steam = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.8
      ..color = AppColors.primary;
    for (final dx in [-0.18, 0.18]) {
      canvas.drawPath(
        Path()
          ..moveTo(c.dx + r * dx, c.dy - r * 0.2)
          ..quadraticBezierTo(c.dx + r * (dx + 0.18), c.dy - r * 0.4, c.dx + r * dx, c.dy - r * 0.62),
        steam,
      );
    }
    _text(canvas, 'SOMOS', Offset(c.dx, c.dy + r * 1.35), g.topW * 0.075, AppColors.primary, spacing: 1.4);
    _text(canvas, 'CAFÉ', Offset(c.dx, c.dy + r * 1.35 + g.topW * 0.085), g.topW * 0.075, AppColors.primary, spacing: 3);
  }

  // ───────────── Etiqueta con el nombre ─────────────

  /// Pegatina con el nombre de la bebida (o el que le puso el usuario).
  void _nameLabel(Canvas canvas, CupGeo g) {
    final text = snap.label.trim();
    if (text.isEmpty) return;
    final h = g.cupH * 0.085;
    final w = g.topW * 0.48;
    final c = Offset(g.cx + g.topW * 0.12, g.topY + g.cupH * 0.72);
    final rect = RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: w, height: h), Radius.circular(h / 2));
    canvas.drawRRect(rect, Paint()..color = StudioColors.cream);
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = AppColors.primary.withValues(alpha: 0.6),
    );
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: AppColors.primary, fontSize: h * 0.46, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: w * 0.88);
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  // ───────────── Condensación (fría) ─────────────

  void _condensation(Canvas canvas, CupGeo g) {
    if (cold <= 0) return;
    final rnd = math.Random(21);
    final count = (16 * cold).round();
    for (var i = 0; i < 16; i++) {
      final y = g.topY + g.cupH * (0.1 + rnd.nextDouble() * 0.62);
      final side = (rnd.nextDouble() - 0.4) * 2 * (g.halfWidthAt(y) - g.topW * 0.05);
      final x = g.cx + side;
      if (i >= count || (x > g.windowLeft(y) - 4 && x < g.windowRight(y) + 4)) continue;
      final slide = ((time * 0.15 + rnd.nextDouble()) % 1.0) * g.cupH * 0.05;
      final rect = Rect.fromCenter(center: Offset(x, y + slide), width: 4 + rnd.nextDouble() * 3, height: 6 + rnd.nextDouble() * 5);
      canvas.drawOval(rect, Paint()..color = const Color(0xFFBFE3F2).withValues(alpha: 0.55));
      canvas.drawOval(rect.deflate(1).translate(-0.8, -1), Paint()..color = Colors.white.withValues(alpha: 0.8));
    }
  }

  // ───────────── Boca abierta ─────────────

  void _opening(Canvas canvas, CupGeo g) {
    final rim = g.rimRect;
    // Vista cenital: el borde del vaso se ve como un aro de papel con la
    // franja de la marca (se funde desde el cuerpo mientras sube la cámara).
    if (top > 0.01) {
      final ring = rim.inflate(g.topW * 0.02);
      canvas.saveLayer(ring.inflate(4), Paint()..color = Colors.white.withValues(alpha: top.clamp(0.0, 1.0).toDouble()));
      canvas.drawOval(ring, Paint()..shader = const RadialGradient(colors: [Color(0xFFFFFAF0), Color(0xFFE6D5BB)]).createShader(rim));
      canvas.drawOval(
        rim.deflate(rim.width * 0.017),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = rim.width * 0.07
          ..color = AppColors.primary,
      );
      canvas.restore();
    }
    // Interior de cartón (con luz desde arriba a la izquierda: la pared
    // del fondo derecho recibe más luz que la del frente izquierdo).
    final inner = top > 0.01 ? rim.deflate(rim.width * 0.06) : rim;
    canvas.drawOval(
      inner,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(const Color(0xFF6B4B33), const Color(0xFF42291A), top)!, Color.lerp(const Color(0xFF6B4B33), const Color(0xFF8A6446), top)!],
        ).createShader(inner),
    );

    // Nivel real del líquido: cuanto más vacío, más abajo se ve.
    final surfaceColor = snap.surfaceColor;
    final (center, rx, ry) = g.visibleSurface(snap.fill);

    canvas.save();
    canvas.clipPath(Path()..addOval(rim.deflate(1.5)));
    canvas.drawOval(Rect.fromCenter(center: center, width: rx * 2, height: ry * 2), Paint()..color = surfaceColor);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: rx * 1.5, height: ry * 1.5),
      Paint()..color = Color.lerp(surfaceColor, snap.baseColor, 0.18)!.withValues(alpha: 0.5),
    );

    // Superficie bien definida: borde más oscuro de crema, menisco claro y
    // un reflejo suave arriba a la izquierda.
    final surf = Rect.fromCenter(center: center, width: rx * 2, height: ry * 2);
    canvas.drawOval(
      surf,
      Paint()..shader = RadialGradient(colors: [Colors.transparent, Colors.black.withValues(alpha: 0.16 + 0.1 * top)], stops: const [0.72, 1]).createShader(surf),
    );
    // Sombra que proyecta el borde sobre la bebida (luz arriba a la izquierda).
    if (top > 0.01) {
      canvas.drawArc(
        surf.deflate(rx * 0.03),
        math.pi * 0.85,
        math.pi * 0.9,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = rx * 0.1
          ..color = Colors.black.withValues(alpha: 0.16 * top)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }
    canvas.drawOval(
      surf.deflate(rx * 0.02),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, rx * 0.035)
        ..color = Color.lerp(surfaceColor, Colors.white, 0.45)!.withValues(alpha: 0.6),
    );
    canvas.drawArc(
      surf.deflate(rx * 0.14),
      math.pi * 1.08,
      math.pi * 0.32,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = math.max(1.2, rx * 0.04)
        ..color = Colors.white.withValues(alpha: 0.28),
    );

    SurfaceDecor.syrups(canvas, center, rx, ry, snap.syrups);
    _art(canvas, center, rx, ry);

    if (cold > 0) _iceTop(canvas, center, rx, ry);
    if (effect != PourKind.none && effectT > 0 && effectT < 1) {
      SurfaceDecor.pour(canvas, center, rx, ry, snap, effect, effectT, effectSeed, time);
    }
    canvas.restore();

    // Labio del vaso.
    Watercolor.ink(canvas, Path()..addOval(rim), StudioColors.ink, width: 2.4);
    Watercolor.ink(canvas, Path()..addOval(rim.inflate(g.topW * 0.018)), StudioColors.ink.withValues(alpha: 0.6), width: 1.6);
    // Contorno de temperatura en el labio del vaso.
    ThermalOutline.stroke(canvas, Path()..addOval(rim.inflate(g.topW * 0.018)), rim.inflate(g.topW * 0.02), cold: cold, time: time, width: 1.8, intensity: 0.8, glow: top > 0.5 && quality >= 0.75, dark: dark);
    // Brillo del borde (más marcado desde arriba).
    if (top > 0.01) {
      canvas.drawArc(
        rim.deflate(rim.width * 0.035),
        math.pi * 1.1,
        math.pi * 0.35,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 3
          ..color = Colors.white.withValues(alpha: 0.6 * top),
      );
    }

    // Toppings (la crema sobresale del borde): entran animados y la
    // vista de lado y la de arriba se funden con la cámara.
    SurfaceDecor.toppings(canvas, center, rx, ry, snap.toppings, hasArt: snap.latteArt.isNotEmpty, qty: snap.toppingQty, progress: toppingProgress, topMix: top);

    _surface = (center, rx, ry);
  }

  /// Arte latte sobre la crema: la silueta guía y la leche que el
  /// usuario va vertiendo; al terminar, el diseño completo (con un
  /// fundido corto desde la leche vertida).
  void _art(Canvas canvas, Offset c, double rx, double ry) {
    final live = pour;
    final done = snap.latteArt.isNotEmpty ? snap.latteArt : ((live?.completed ?? false) ? live!.design : '');
    final guiding = live != null && live.hasDesign && !live.completed;
    if (done.isEmpty && !guiding) return;

    ArtPour.crema(canvas, c, rx, ry, snap.baseColor);

    if (live != null && live.hasDesign && (guiding || artSettle < 1)) {
      ArtPour.paintLive(canvas, c, rx, ry, live, guide: guiding);
    }
    if (done.isEmpty) return;

    if (live != null && artSettle < 1) {
      canvas.saveLayer(
        Rect.fromCenter(center: c, width: rx * 2.4, height: ry * 2.4),
        Paint()..color = Colors.white.withValues(alpha: artSettle.clamp(0.0, 1.0).toDouble()),
      );
      SurfaceDecor.art(canvas, c, rx, ry, done, 1);
      canvas.restore();
    } else {
      SurfaceDecor.art(canvas, c, rx, ry, done, 1);
    }
  }

  void _iceTop(Canvas canvas, Offset c, double rx, double ry) {
    const dx = [-0.45, 0.1, 0.5];
    const dy = [-0.1, 0.25, -0.2];
    for (var i = 0; i < 3; i++) {
      canvas.save();
      canvas.translate(c.dx + rx * dx[i], c.dy + ry * dy[i] + math.sin(time * 1.4 + i) * 1.2);
      canvas.rotate(0.4 + i * 0.6);
      final r = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: rx * 0.34, height: rx * 0.34), const Radius.circular(5));
      canvas.drawRRect(r, Paint()..color = Colors.white.withValues(alpha: 0.4 * cold));
      canvas.drawRRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = Colors.white.withValues(alpha: 0.9 * cold),
      );
      canvas.restore();
    }
  }

  /// Jarrita de leche del arte latte (se dibuja por encima de todo).
  void _jug(Canvas canvas, CupGeo g) {
    final surface = _surface;
    if (surface == null || scene.jugShow <= 0) return;
    ArtPour.paint(canvas, surface.$1, surface.$2, surface.$3, g.topW * 0.36, snap, scene, time);
  }

  /// Destellos al terminar el diseño (por encima de todo).
  void _celebrate(Canvas canvas) {
    final surface = _surface;
    if (surface == null || celebrate >= 1) return;
    ArtPour.celebrate(canvas, surface.$1, surface.$2, surface.$3, celebrate);
  }

  // ───────────── Vapor ─────────────

  void _steam(Canvas canvas, CupGeo g) {
    // Nace de la superficie del café y se adapta a la boca del vaso. Se
    // enciende y se apaga de forma gradual con la temperatura.
    final strength = (1 - cold) * (1 - lid);
    if (strength <= 0.02 || !snap.isHot && cold >= 1) return;
    final surface = _surface;
    if (surface == null) return;
    final (c, rx, ry) = surface;
    SteamField.paint(
      canvas,
      origin: Offset(c.dx, c.dy - ry * 0.25),
      width: rx * 1.7,
      height: g.fullCupH * 0.85 * (1 - 0.45 * top),
      time: time,
      strength: strength,
      dark: dark,
      quality: quality,
      spread: top,
    );
  }

  /// Con la bebida caliente ya tapada, un hilo de vapor sale por la boquilla.
  void _lidSteam(Canvas canvas, CupGeo g) {
    final strength = ((lid - 0.9) / 0.1).clamp(0.0, 1.0).toDouble() * (1 - cold);
    if (strength <= 0.02) return;
    SteamField.paint(
      canvas,
      origin: Offset(g.cx + g.topW * 1.1 * 0.17, g.topY - g.cupH * 0.05),
      width: g.topW * 0.28,
      height: g.cupH * 0.42,
      time: time,
      strength: strength,
      dark: dark,
      quality: quality * 0.6,
    );
  }

  // ───────────── Tapa ─────────────

  void _lid(Canvas canvas, CupGeo g) {
    if (lid <= 0) return;
    final lidT = lid.clamp(0.0, 1.0).toDouble();
    final ease = Curves.easeOutBack.transform(lidT);
    final drop = (1 - ease) * g.cupH * 0.7;
    final w = g.topW * 1.1;
    canvas.save();
    canvas.translate(0, -drop);
    canvas.saveLayer(null, Paint()..color = Colors.white.withValues(alpha: lidT));

    final base = Rect.fromCenter(center: Offset(g.cx, g.topY), width: w, height: g.rimRy * 2.15);
    final isCold = cold > 0.5;
    if (isCold) {
      // Tapa fría: aro plano + domo transparente con brillo y pitillo rayado.
      canvas.drawOval(base, Paint()..color = Colors.white.withValues(alpha: 0.38));
      final domeH = g.cupH * 0.14;
      final dome = Path()
        ..moveTo(g.cx - w / 2, g.topY)
        ..quadraticBezierTo(g.cx - w * 0.42, g.topY - domeH * 1.6, g.cx, g.topY - domeH * 1.55)
        ..quadraticBezierTo(g.cx + w * 0.42, g.topY - domeH * 1.6, g.cx + w / 2, g.topY)
        ..close();
      canvas.drawPath(dome, Paint()..color = Colors.white.withValues(alpha: 0.5));
      Watercolor.ink(canvas, dome, StudioColors.ink, width: 2);
      // Brillo del domo.
      canvas.drawPath(
        Path()
          ..moveTo(g.cx - w * 0.34, g.topY - domeH * 0.55)
          ..quadraticBezierTo(g.cx - w * 0.3, g.topY - domeH * 1.2, g.cx - w * 0.1, g.topY - domeH * 1.38),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 2.6
          ..color = Colors.white.withValues(alpha: 0.85),
      );
      // Pitillo con rayas.
      final a = Offset(g.cx + g.topW * 0.12, g.topY - domeH * 1.55 - g.cupH * 0.2);
      final b = Offset(g.cx - g.topW * 0.06, g.topY + g.cupH * 0.22);
      final strawW = math.max(4.0, g.topW * 0.045);
      canvas.drawLine(
        a,
        b,
        Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strawW
          ..color = AppColors.primary,
      );
      for (var k = 0; k < 6; k++) {
        final t0 = 0.06 + k * 0.16;
        canvas.drawLine(
          Offset.lerp(a, b, t0)!,
          Offset.lerp(a, b, t0 + 0.07)!,
          Paint()
            ..strokeWidth = strawW * 0.6
            ..color = StudioColors.cream.withValues(alpha: 0.9),
        );
      }
      // Aro por donde entra el pitillo.
      canvas.drawOval(
        Rect.fromCenter(center: Offset.lerp(a, b, 0.3)!.translate(0, -domeH * 0.1), width: g.topW * 0.1, height: g.rimRy * 0.3),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = Colors.white.withValues(alpha: 0.9),
      );
    } else {
      // Tapa caliente: sombra, disco, anillo elevado, boquilla con borde y respiradero.
      canvas.drawOval(base.translate(0, g.rimRy * 0.25), Paint()..color = Colors.black.withValues(alpha: 0.1));
      canvas.drawOval(base, Paint()..color = const Color(0xFFFFFAF0));
      canvas.drawOval(
        Rect.fromCenter(center: Offset(g.cx, g.topY - g.cupH * 0.012), width: w * 0.92, height: g.rimRy * 1.95),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..color = const Color(0xFFE7D7BE),
      );
      final cap = Rect.fromCenter(center: Offset(g.cx, g.topY - g.cupH * 0.025), width: w * 0.8, height: g.rimRy * 1.7);
      canvas.drawOval(cap, Paint()..color = const Color(0xFFFFF3DE));
      final hole = Rect.fromCenter(center: Offset(g.cx + w * 0.17, g.topY - g.cupH * 0.02), width: w * 0.2, height: g.rimRy * 0.5);
      canvas.drawOval(hole.inflate(2.5), Paint()..color = const Color(0xFFE9DAC2));
      canvas.drawOval(hole, Paint()..color = const Color(0xFF4A2C1B));
      canvas.drawCircle(Offset(g.cx - w * 0.2, g.topY - g.cupH * 0.02), g.rimRy * 0.1, Paint()..color = const Color(0xFF4A2C1B).withValues(alpha: 0.8));
      Watercolor.ink(canvas, Path()..addOval(cap), StudioColors.ink, width: 1.8);
      canvas.drawArc(
        cap.deflate(3),
        math.pi * 1.05,
        math.pi * 0.5,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 2
          ..color = Colors.white.withValues(alpha: 0.7),
      );
    }
    Watercolor.ink(canvas, Path()..addOval(base), StudioColors.ink, width: 2.2);
    canvas.drawOval(base.deflate(2), Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColors.primary.withValues(alpha: 0.55));

    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant TakeawayCupPainter old) => true;
}
