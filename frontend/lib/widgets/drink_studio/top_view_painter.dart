import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/cup_snapshot.dart';
import 'art_pour.dart';
import 'studio_colors.dart';
import 'surface_decor.dart';
import 'sweetener_packet.dart';
import 'watercolor.dart';

/// Vista desde arriba: plato, vaso con su aro de marca y, en el centro,
/// la superficie de la bebida con el latte art y los toppings. Con
/// latte art la crema batida va en corona y el diseño queda a la vista.
class TopViewPainter extends CustomPainter {
  TopViewPainter({
    required this.snap,
    required this.time,
    required this.effect,
    required this.effectT,
    required this.effectSeed,
    required this.dark,
  });

  final CupSnapshot snap;
  final double time;
  final PourKind effect;
  final double effectT;
  final int effectSeed;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    final hasPackets = snap.sweeteners.isNotEmpty;
    // Con endulzantes, la taza se achica un poco para dejar sitio a sus sobres.
    final c = hasPackets ? Offset(size.width * 0.46, size.height * 0.46) : Offset(size.width / 2, size.height / 2);
    final r = side / 2 * 0.86 * (hasPackets ? 0.84 : 1.0) * (0.9 + 0.1 * (snap.sizeFactor / 1.14).clamp(0.7, 1.0).toDouble());

    // Plato con sombra y textura de acuarela.
    canvas.drawCircle(
      c.translate(0, r * 0.07),
      r * 1.16,
      Paint()
        ..color = Colors.black.withValues(alpha: dark ? 0.35 : 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
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

    // Vaso visto desde arriba: papel + aro de marca.
    final cupRect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()..shader = const RadialGradient(colors: [Color(0xFFFFFAF0), Color(0xFFE6D5BB)]).createShader(cupRect),
    );
    canvas.drawCircle(
      c,
      r * 0.965,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.07
        ..color = AppColors.primary,
    );
    Watercolor.ink(canvas, Path()..addOval(cupRect), StudioColors.ink, width: 2.4);

    // Interior y superficie.
    canvas.drawCircle(c, r * 0.88, Paint()..color = const Color(0xFF6B4B33));
    final baseFrac = snap.isCoffee ? math.min(0.16 + 0.055 * snap.shots, 0.46) : 0.5;
    final fill = (baseFrac + math.max(0.0, math.min(snap.milkLevel * 0.62, 0.9 - baseFrac))).clamp(0.0, 1.0);
    final sr = r * (0.8 - 0.06 * (1 - fill));
    final surface = Rect.fromCircle(center: c, radius: sr);
    canvas.drawCircle(
      c,
      sr,
      Paint()
        ..shader = RadialGradient(
          colors: [snap.surfaceColor, Color.lerp(snap.surfaceColor, snap.baseColor, 0.45)!],
          stops: const [0.55, 1],
        ).createShader(surface),
    );
    Watercolor.ink(canvas, Path()..addOval(surface), StudioColors.ink.withValues(alpha: 0.5), width: 1.4);

    canvas.save();
    canvas.clipPath(Path()..addOval(surface));
    SurfaceDecor.syrups(canvas, c, sr, sr, snap.syrups);
    if (snap.latteArt.isNotEmpty) ArtPour.crema(canvas, c, sr, sr, snap.baseColor);
    SurfaceDecor.art(canvas, c, sr, sr, snap.latteArt, 1);
    canvas.restore();

    SurfaceDecor.toppings(canvas, c, sr, sr, snap.toppings, hasArt: snap.latteArt.isNotEmpty, topView: true, qty: snap.toppingQty);

    if (effect != PourKind.none && effectT > 0 && effectT < 1) {
      SurfaceDecor.pour(canvas, c, sr, sr, snap, effect, effectT, effectSeed, time);
    }

    // Brillo del borde.
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * 0.93),
      math.pi * 1.1,
      math.pi * 0.35,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3
        ..color = Colors.white.withValues(alpha: 0.6),
    );
    // Sobres de endulzante apoyados junto al plato.
    if (hasPackets) {
      final n = snap.sweeteners.length;
      final w = math.min(r * 0.36, size.width * 0.13);
      final h = w * SweetenerPacketPainter.aspect;
      for (var i = n - 1; i >= 0; i--) {
        final center = Offset(size.width - w * 0.85 - i * w * 0.5, size.height - h * 0.62 - i * w * 0.05);
        SweetenerPacketPainter.paint(canvas, center, w, snap.sweeteners[i], angle: -0.22 + i * 0.16);
      }
    }
    Watercolor.grain(canvas, size);
  }

  @override
  bool shouldRepaint(covariant TopViewPainter old) => true;
}
