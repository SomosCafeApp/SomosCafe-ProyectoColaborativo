import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/cup_snapshot.dart';
import 'art_pour.dart';
import 'cup_geometry.dart';
import 'latte_pour_session.dart';
import 'studio_colors.dart';
import 'surface_decor.dart';
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

  /// 0 = sin tapa … 1 = tapa puesta.
  final double lid;
  final bool dark;

  static const Color _paper = Color(0xFFFFFAF0);

  /// Centro y radios de la superficie (se calculan en _opening).
  (Offset, double, double)? _surface;

  @override
  void paint(Canvas canvas, Size size) {
    final g = CupGeo(size, snap.sizeFactor, tilt: tilt);

    _shadow(canvas, g);
    _body(canvas, g);
    _window(canvas, g);
    _brand(canvas, g);
    _nameLabel(canvas, g);
    _condensation(canvas, g);
    _opening(canvas, g);
    if (lid < 1) _steam(canvas, g);
    _lid(canvas, g);
    _jug(canvas, g);
    _celebrate(canvas);

    Watercolor.grain(canvas, size);
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
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          colors: [_paper, Color.lerp(_paper, const Color(0xFFD9C3A3), 0.45)!],
        ).createShader(rect),
    );

    // Franja inferior de la marca con las onzas.
    canvas.save();
    canvas.clipPath(body);
    final bandTop = g.baseY - g.cupH * 0.15;
    canvas.drawRect(Rect.fromLTRB(g.cx - g.topW, bandTop, g.cx + g.topW, g.baseY + 30), Paint()..color = AppColors.primary);
    canvas.drawRect(Rect.fromLTRB(g.cx - g.topW, bandTop, g.cx + g.topW, bandTop + 2.2), Paint()..color = StudioColors.cream.withValues(alpha: 0.7));

    // Sombra en el costado derecho y un brillo vertical: el vaso gana volumen.
    final shade = Rect.fromLTRB(g.cx + g.topW * 0.22, g.topY, g.cx + g.topW * 0.55, g.baseY);
    canvas.drawRect(
      shade,
      Paint()..shader = LinearGradient(colors: [Colors.transparent, Colors.black.withValues(alpha: dark ? 0.22 : 0.12)]).createShader(shade),
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
    // Interior de cartón.
    canvas.drawOval(rim, Paint()..color = const Color(0xFF6B4B33));

    // Nivel real del líquido: cuanto más vacío, más abajo se ve.
    final surfaceColor = snap.surfaceColor;
    final (center, rx, ry) = g.surface(snap.fill);

    canvas.save();
    canvas.clipPath(Path()..addOval(rim.deflate(1.5)));
    canvas.drawOval(Rect.fromCenter(center: center, width: rx * 2, height: ry * 2), Paint()..color = surfaceColor);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: rx * 1.5, height: ry * 1.5),
      Paint()..color = Color.lerp(surfaceColor, snap.baseColor, 0.18)!.withValues(alpha: 0.5),
    );

    SurfaceDecor.syrups(canvas, center, rx, ry, snap.syrups);
    SurfaceDecor.sweeteners(canvas, center, rx, ry, snap.sweeteners);
    _art(canvas, center, rx, ry);

    if (cold > 0) _iceTop(canvas, center, rx, ry);
    if (effect != PourKind.none && effectT > 0 && effectT < 1) {
      SurfaceDecor.pour(canvas, center, rx, ry, snap, effect, effectT, effectSeed, time);
    }
    canvas.restore();

    // Labio del vaso.
    Watercolor.ink(canvas, Path()..addOval(rim), StudioColors.ink, width: 2.4);
    Watercolor.ink(canvas, Path()..addOval(rim.inflate(g.topW * 0.018)), StudioColors.ink.withValues(alpha: 0.6), width: 1.6);

    // Toppings (la crema sobresale del borde).
    SurfaceDecor.toppings(canvas, center, rx, ry, snap.toppings, hasArt: snap.latteArt.isNotEmpty);

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
    final strength = (1 - cold) * (1 - lid);
    if (strength <= 0.02 || !snap.isHot && cold >= 1) return;
    for (var i = 0; i < 3; i++) {
      final x0 = g.cx + (i - 1) * g.topW * 0.22;
      final path = Path()..moveTo(x0, g.topY - g.rimRy * 0.5);
      for (var k = 1; k <= 8; k++) {
        path.lineTo(x0 + math.sin(time * 1.6 + i * 1.7 + k * 0.7) * g.topW * 0.025 * k / 2, g.topY - g.rimRy * 0.5 - k * g.cupH * 0.07);
      }
      final alpha = (0.2 + 0.2 * (0.5 + 0.5 * math.sin(time * 1.2 + i))) * strength;
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 3.4
          ..color = (dark ? StudioColors.cream : Colors.white).withValues(alpha: alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.6),
      );
    }
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
      final domeH = g.cupH * 0.14;
      final dome = Path()
        ..moveTo(g.cx - w / 2, g.topY)
        ..quadraticBezierTo(g.cx - w * 0.42, g.topY - domeH * 1.6, g.cx, g.topY - domeH * 1.55)
        ..quadraticBezierTo(g.cx + w * 0.42, g.topY - domeH * 1.6, g.cx + w / 2, g.topY)
        ..close();
      canvas.drawPath(dome, Paint()..color = Colors.white.withValues(alpha: 0.5));
      Watercolor.ink(canvas, dome, StudioColors.ink, width: 2);
      // Pitillo.
      final straw = Path()
        ..moveTo(g.cx + g.topW * 0.12, g.topY - domeH * 1.55 - g.cupH * 0.2)
        ..lineTo(g.cx - g.topW * 0.06, g.topY + g.cupH * 0.22);
      Watercolor.ink(canvas, straw, AppColors.primary, width: math.max(4, g.topW * 0.045));
    } else {
      canvas.drawOval(base, Paint()..color = const Color(0xFFFFFAF0));
      final cap = Rect.fromCenter(center: Offset(g.cx, g.topY - g.cupH * 0.025), width: w * 0.8, height: g.rimRy * 1.7);
      canvas.drawOval(cap, Paint()..color = const Color(0xFFFFF3DE));
      canvas.drawOval(Rect.fromCenter(center: Offset(g.cx + w * 0.17, g.topY - g.cupH * 0.02), width: w * 0.2, height: g.rimRy * 0.5), Paint()..color = const Color(0xFF4A2C1B));
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
