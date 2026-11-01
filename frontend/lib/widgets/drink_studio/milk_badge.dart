import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../animations/motion.dart';
import '../../core/utils/studio_prefs.dart';
import '../../models/cup_snapshot.dart';
import 'cup_geometry.dart';
import 'studio_colors.dart';

/// Ilustración breve que aparece al elegir una leche: vaca (entera),
/// soya, almendra o planta de avena. Si el nombre no coincide con
/// ninguna, muestra una gota genérica (no se inventa un origen).
enum MilkKind { cow, lactoseFree, soy, almond, oat, generic }

MilkKind milkKindOf(String name) {
  final n = name.toLowerCase();
  if (n.contains('deslact')) return MilkKind.lactoseFree;
  if (n.contains('entera') || n.contains('vaca')) return MilkKind.cow;
  if (n.contains('soya') || n.contains('soja')) return MilkKind.soy;
  if (n.contains('almendra')) return MilkKind.almond;
  if (n.contains('avena')) return MilkKind.oat;
  return MilkKind.generic;
}

/// Color de la leche que cae (no el del café ya mezclado).
Color milkTint(MilkKind kind) => switch (kind) {
      MilkKind.cow => const Color(0xFFFFFBF2),
      MilkKind.lactoseFree => const Color(0xFFFFF8EA),
      MilkKind.soy => const Color(0xFFF3E6C4),
      MilkKind.almond => const Color(0xFFF1DDBE),
      MilkKind.oat => const Color(0xFFE9D3A4),
      MilkKind.generic => const Color(0xFFFFF4E0),
    };

/// Al elegir una leche, un cartón (con los colores de ESA leche) entra,
/// se inclina y vierte un chorro continuo sobre el café: hay ondas en la
/// superficie, salpicaduras sutiles y la mezcla se difumina antes de que
/// el cartón se retire. Una pequeña etiqueta confirma la elección.
/// Con "reducir movimiento" solo se muestra la etiqueta.
class MilkPourOverlay extends StatefulWidget {
  const MilkPourOverlay({super.key, required this.tick, required this.name, required this.snapshot});

  final int tick;
  final String name;
  final CupSnapshot snapshot;

  @override
  State<MilkPourOverlay> createState() => _MilkPourOverlayState();
}

class _MilkPourOverlayState extends State<MilkPourOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));
  String _name = '';

  @override
  void didUpdateWidget(MilkPourOverlay old) {
    super.didUpdateWidget(old);
    if (old.tick != widget.tick && widget.name.isNotEmpty) {
      _name = widget.name;
      if (Motion.reduced(context) || !StudioPrefs.instance.animations) {
        _c.value = 0.62; // solo la etiqueta
        _c.animateTo(1, duration: const Duration(milliseconds: 900));
      } else {
        _c.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final reduced = Motion.reduced(context) || !StudioPrefs.instance.animations;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          if (_name.isEmpty || _c.value <= 0 || _c.value >= 1) return const SizedBox.shrink();
          final t = _c.value;
          // Etiqueta: aparece cuando empieza el vertido y se va al final.
          final chip = (Curves.easeOut.transform(((t - 0.5) / 0.12).clamp(0.0, 1.0).toDouble()) * (1 - Curves.easeIn.transform(((t - 0.9) / 0.1).clamp(0.0, 1.0).toDouble()))).clamp(0.0, 1.0).toDouble();
          return Stack(
            fit: StackFit.expand,
            children: [
              if (!reduced)
                CustomPaint(
                  painter: MilkPourPainter(t: t, kind: milkKindOf(_name), snap: widget.snapshot, quality: StudioPrefs.instance.lowPower ? 0.5 : 1),
                ),
              Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Opacity(
                    opacity: chip,
                    child: Transform.translate(
                      offset: Offset(0, (1 - chip) * -8),
                      child: Semantics(
                        liveRegion: true,
                        label: 'Leche elegida: $_name',
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(8, 6, 14, 6),
                          decoration: BoxDecoration(
                            color: StudioColors.panel(dark),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: StudioColors.primary, width: 1.4),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 30, height: 30, child: CustomPaint(painter: MilkIllustrationPainter(milkKindOf(_name)))),
                              const SizedBox(width: 8),
                              Text(_name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: StudioColors.text(dark))),
                              const SizedBox(width: 6),
                              const Icon(Icons.check_circle_rounded, size: 16, color: StudioColors.primary),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Pinta el cartón, el chorro y las salpicaduras sobre el escenario.
/// Usa la MISMA geometría del vaso (CupGeo) para que el chorro caiga
/// exactamente sobre la superficie del café.
class MilkPourPainter extends CustomPainter {
  MilkPourPainter({required this.t, required this.kind, required this.snap, this.quality = 1});

  final double t;
  final MilkKind kind;
  final CupSnapshot snap;
  final double quality;

  static double _seg(double v, double a, double b) => ((v - a) / (b - a)).clamp(0.0, 1.0).toDouble();

  /// Colores del cartón por tipo de leche: (cuerpo, franja, tapa).
  (Color, Color, Color) get _pack => switch (kind) {
        MilkKind.cow => (const Color(0xFFFFFFFF), const Color(0xFF4A90C2), const Color(0xFFDCE9F4)),
        MilkKind.lactoseFree => (const Color(0xFFFFFFFF), const Color(0xFF58A36C), const Color(0xFFDDEEDD)),
        MilkKind.soy => (const Color(0xFFF6F0DA), const Color(0xFF7BA05B), const Color(0xFFE3EBC9)),
        MilkKind.almond => (const Color(0xFFFBEFE0), const Color(0xFFB07A4F), const Color(0xFFEBD2B5)),
        MilkKind.oat => (const Color(0xFFF4E7C8), const Color(0xFFC49A3A), const Color(0xFFE8D49C)),
        MilkKind.generic => (const Color(0xFFFFFFFF), const Color(0xFF9E6D41), const Color(0xFFEADCC6)),
      };

  @override
  void paint(Canvas canvas, Size size) {
    final g = CupGeo(size, snap.sizeFactor);
    final (c, rx, ry) = g.visibleSurface(snap.fill);

    final enter = Curves.easeOutCubic.transform(_seg(t, 0.0, 0.24));
    final leave = Curves.easeInCubic.transform(_seg(t, 0.76, 1.0));
    final tilt = Curves.easeInOutCubic.transform(_seg(t, 0.12, 0.34)) - Curves.easeInOutCubic.transform(_seg(t, 0.7, 0.8));

    final cw = math.min(size.width * 0.2, 68.0);
    final ch = cw * 1.5;

    // Posición de la boquilla: llega desde arriba a la derecha y se coloca
    // sobre el centro del vaso; al final se retira por el mismo camino.
    final rest = Offset(c.dx + rx * 0.45, c.dy - g.fullCupH * 0.62);
    final away = Offset(size.width + cw, rest.dy - ch * 0.8);
    final from = Offset.lerp(rest, away, 1 - enter)!;
    final spout = Offset.lerp(from, away, leave)!;

    // El cartón gira alrededor de su centro; la boquilla es la esquina
    // superior izquierda del cartón ya inclinado.
    final angle = -tilt * 1.85;
    final localSpout = Offset(-cw * 0.5, -ch * 0.5);
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    final rotated = Offset(localSpout.dx * cosA - localSpout.dy * sinA, localSpout.dx * sinA + localSpout.dy * cosA);
    final center = spout - rotated;

    final milk = milkTint(kind);

    // ── Chorro ──
    final pouring = _seg(t, 0.28, 0.36) * (1 - _seg(t, 0.66, 0.74));
    final impact = Offset(c.dx - rx * 0.05, c.dy + ry * 0.12);
    final grow = Curves.easeOut.transform(_seg(t, 0.28, 0.4));
    final tail = Curves.easeIn.transform(_seg(t, 0.62, 0.76));
    if (pouring > 0.01 || (grow > 0 && tail < 1)) {
      _stream(canvas, spout, impact, milk, grow, tail, pouring, cw);
    }

    // ── Impacto: ondas, mezcla y salpicaduras ──
    final hit = _seg(t, 0.36, 1.0);
    if (grow >= 1 && hit > 0) {
      final live = pouring > 0.01 ? 1.0 : (1 - _seg(t, 0.74, 0.95));
      _impact(canvas, c, rx, ry, impact, milk, hit, live);
    }

    // ── Cartón ──
    final visible = 1 - _seg(t, 0.9, 1.0);
    if (visible > 0.01) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      _carton(canvas, cw, ch, visible);
      canvas.restore();
    }
  }

  void _stream(Canvas canvas, Offset from, Offset to, Color milk, double grow, double tail, double strength, double cw) {
    // Parábola: sale casi horizontal y cae por gravedad.
    Offset at(double u) => Offset(from.dx + (to.dx - from.dx) * (1 - math.pow(1 - u, 2)), from.dy + (to.dy - from.dy) * u * u);
    final path = Path()..moveTo(from.dx, from.dy);
    const steps = 18;
    final a = tail.clamp(0.0, 0.98).toDouble();
    final b = grow.clamp(0.0, 1.0).toDouble();
    if (b <= a) return;
    for (var i = 0; i <= steps; i++) {
      final u = a + (b - a) * i / steps;
      // Ligera ondulación: el hilo de leche no es una recta perfecta.
      final wob = math.sin(u * 14 + t * 26) * 1.1 * u;
      final p = at(u).translate(wob, 0);
      if (i == 0) {
        path.reset();
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    final w = math.max(2.0, cw * 0.1 * (0.4 + 0.6 * strength));
    final shade = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = w * 1.25
      ..color = const Color(0xFFD9C4A6).withValues(alpha: 0.75);
    canvas.drawPath(path, shade);
    canvas.drawPath(path, shade..strokeWidth = w..color = milk);
    canvas.drawPath(
      path.shift(Offset(-w * 0.16, 0)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = w * 0.28
        ..color = Colors.white.withValues(alpha: 0.9),
    );
  }

  void _impact(Canvas canvas, Offset c, double rx, double ry, Offset hitPoint, Color milk, double hit, double live) {
    final surf = Rect.fromCenter(center: c, width: rx * 2, height: ry * 2);
    canvas.save();
    canvas.clipPath(Path()..addOval(surf));
    // Mancha de leche que se difumina en el café.
    final blob = Curves.easeOut.transform(hit);
    final r = rx * (0.15 + 0.7 * blob);
    canvas.drawOval(
      Rect.fromCenter(center: hitPoint, width: r * 2, height: r * 2 * (ry / rx)),
      Paint()
        ..shader = RadialGradient(colors: [milk.withValues(alpha: 0.55 * live), milk.withValues(alpha: 0)]).createShader(Rect.fromCenter(center: hitPoint, width: r * 2, height: r * 2 * (ry / rx))),
    );
    // Ondas concéntricas.
    for (var k = 0; k < 3; k++) {
      final p = ((hit * 2.4) - k * 0.35) % 1.0;
      final rr = rx * (0.08 + 0.55 * p);
      canvas.drawOval(
        Rect.fromCenter(center: hitPoint, width: rr * 2, height: rr * 2 * (ry / rx)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = Colors.white.withValues(alpha: 0.5 * (1 - p) * live),
      );
    }
    canvas.restore();

    // Salpicaduras: gotas pequeñas con trayectoria balística.
    final drops = quality >= 0.75 ? 9 : 5;
    for (var i = 0; i < drops; i++) {
      final ang = -math.pi * (0.15 + 0.7 * ((i * 0.618) % 1.0));
      final speed = rx * (0.7 + 0.5 * ((i * 0.37) % 1.0));
      final period = 0.34;
      final tau = ((hit * 3.0) + i * 0.19) % 1.0 * period * 2;
      final p = hitPoint + Offset(math.cos(ang) * speed * tau * (i.isEven ? 1 : -1), math.sin(ang) * speed * tau + 0.5 * rx * 4 * tau * tau);
      final fade = (1 - tau / (period * 2)).clamp(0.0, 1.0).toDouble() * live;
      if (fade <= 0.02) continue;
      canvas.drawCircle(p, math.max(1.1, rx * 0.025) * (0.6 + 0.4 * fade), Paint()..color = milk.withValues(alpha: 0.9 * fade));
    }
  }

  void _carton(Canvas canvas, double w, double h, double alpha) {
    final (body, stripe, cap) = _pack;
    final tintA = alpha.clamp(0.0, 1.0).toDouble();
    const ink = Color(0xFF5A3A24);
    final rect = Rect.fromCenter(center: Offset.zero, width: w, height: h);
    final top = h * 0.24;
    // Cuerpo con la parte superior en pico (como un cartón de leche).
    final shape = Path()
      ..moveTo(rect.left, rect.top + top)
      ..lineTo(rect.left + w * 0.22, rect.top)
      ..lineTo(rect.right - w * 0.22, rect.top)
      ..lineTo(rect.right, rect.top + top)
      ..lineTo(rect.right, rect.bottom - 4)
      ..quadraticBezierTo(rect.right, rect.bottom, rect.right - 4, rect.bottom)
      ..lineTo(rect.left + 4, rect.bottom)
      ..quadraticBezierTo(rect.left, rect.bottom, rect.left, rect.bottom - 4)
      ..close();
    canvas.drawShadow(shape, Colors.black, 3, false);
    canvas.drawPath(shape, Paint()..color = body.withValues(alpha: tintA));
    // Tapa superior y boquilla.
    final roof = Path()
      ..moveTo(rect.left, rect.top + top)
      ..lineTo(rect.left + w * 0.22, rect.top)
      ..lineTo(rect.right - w * 0.22, rect.top)
      ..lineTo(rect.right, rect.top + top)
      ..close();
    canvas.drawPath(roof, Paint()..color = cap.withValues(alpha: tintA));
    // Franja con el color de la leche y su símbolo.
    final band = Rect.fromLTWH(rect.left, rect.top + h * 0.5, w, h * 0.2);
    canvas.save();
    canvas.clipPath(shape);
    canvas.drawRect(band, Paint()..color = stripe.withValues(alpha: tintA));
    canvas.restore();
    final mark = Offset(0, rect.top + h * 0.34);
    switch (kind) {
      case MilkKind.cow:
      case MilkKind.generic:
        canvas.drawCircle(mark, w * 0.13, Paint()..color = stripe.withValues(alpha: tintA));
      case MilkKind.lactoseFree:
        canvas.drawLine(mark.translate(-w * 0.12, w * 0.12), mark.translate(w * 0.12, -w * 0.12), Paint()..color = stripe.withValues(alpha: tintA)..strokeWidth = 2.6..strokeCap = StrokeCap.round);
      case MilkKind.soy:
      case MilkKind.almond:
      case MilkKind.oat:
        canvas.drawOval(Rect.fromCenter(center: mark, width: w * 0.2, height: w * 0.3), Paint()..color = stripe.withValues(alpha: tintA));
    }
    canvas.drawPath(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeJoin = StrokeJoin.round
        ..color = ink.withValues(alpha: tintA),
    );
  }

  @override
  bool shouldRepaint(covariant MilkPourPainter old) => old.t != t || old.kind != kind || old.snap != snap;
}

/// Ilustraciones vectoriales sencillas (cuadro de 64×64).
class MilkIllustrationPainter extends CustomPainter {
  MilkIllustrationPainter(this.kind);
  final MilkKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 64, size.height / 64);
    switch (kind) {
      case MilkKind.cow:
        _cow(canvas);
      case MilkKind.lactoseFree:
        _carton(canvas);
      case MilkKind.soy:
        _soy(canvas);
      case MilkKind.almond:
        _almond(canvas);
      case MilkKind.oat:
        _oat(canvas);
      case MilkKind.generic:
        _drop(canvas);
    }
    canvas.restore();
  }

  Paint _fill(Color c) => Paint()..color = c;
  Paint _line(Color c, double w) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = w
    ..color = c;

  void _cow(Canvas c) {
    const ink = Color(0xFF3B2416);
    // Orejas y cuernos
    c.drawOval(Rect.fromCenter(center: const Offset(12, 22), width: 14, height: 9), _fill(const Color(0xFFF2D6C9)));
    c.drawOval(Rect.fromCenter(center: const Offset(52, 22), width: 14, height: 9), _fill(const Color(0xFFF2D6C9)));
    c.drawPath(Path()..moveTo(22, 14)..quadraticBezierTo(20, 6, 15, 8), _line(const Color(0xFFE0C79A), 3.4));
    c.drawPath(Path()..moveTo(42, 14)..quadraticBezierTo(44, 6, 49, 8), _line(const Color(0xFFE0C79A), 3.4));
    // Cabeza
    final head = RRect.fromRectAndRadius(const Rect.fromLTWH(16, 12, 32, 38), const Radius.circular(15));
    c.drawRRect(head, _fill(Colors.white));
    c.drawRRect(head, _line(ink, 1.8));
    // Manchas
    c.drawOval(Rect.fromCenter(center: const Offset(24, 20), width: 11, height: 9), _fill(ink));
    c.drawOval(Rect.fromCenter(center: const Offset(42, 30), width: 8, height: 10), _fill(ink));
    // Ojos
    c.drawCircle(const Offset(25, 31), 2.1, _fill(ink));
    c.drawCircle(const Offset(39, 31), 2.1, _fill(ink));
    // Hocico
    final muzzle = RRect.fromRectAndRadius(const Rect.fromLTWH(20, 38, 24, 15), const Radius.circular(8));
    c.drawRRect(muzzle, _fill(const Color(0xFFF4B6B6)));
    c.drawOval(Rect.fromCenter(center: const Offset(27, 45), width: 3.4, height: 5), _fill(const Color(0xFF8B4A4A)));
    c.drawOval(Rect.fromCenter(center: const Offset(37, 45), width: 3.4, height: 5), _fill(const Color(0xFF8B4A4A)));
  }

  void _carton(Canvas c) {
    const ink = Color(0xFF5A3A24);
    final box = Path()
      ..moveTo(16, 24)
      ..lineTo(48, 24)
      ..lineTo(48, 58)
      ..lineTo(16, 58)
      ..close();
    final roof = Path()
      ..moveTo(16, 24)
      ..lineTo(24, 8)
      ..lineTo(40, 8)
      ..lineTo(48, 24)
      ..close();
    c.drawPath(box, _fill(Colors.white));
    c.drawPath(roof, _fill(const Color(0xFFEADCC6)));
    c.drawPath(box, _line(ink, 2));
    c.drawPath(roof, _line(ink, 2));
    // Símbolo "sin lactosa": gota tachada.
    final drop = Path()
      ..moveTo(32, 30)
      ..quadraticBezierTo(41, 41, 38, 47)
      ..quadraticBezierTo(32, 53, 26, 47)
      ..quadraticBezierTo(23, 41, 32, 30)
      ..close();
    c.drawPath(drop, _fill(const Color(0xFFCFE4F0)));
    c.drawPath(drop, _line(StudioColors.primary, 2));
    c.drawLine(const Offset(22, 52), const Offset(42, 30), _line(const Color(0xFFE53935), 3));
  }

  void _soy(Canvas c) {
    const green = Color(0xFF7BA05B);
    final pod = Path()
      ..moveTo(10, 40)
      ..quadraticBezierTo(14, 12, 52, 14)
      ..quadraticBezierTo(54, 48, 14, 50)
      ..quadraticBezierTo(8, 48, 10, 40)
      ..close();
    c.drawPath(pod, _fill(green));
    c.drawPath(pod, _line(const Color(0xFF4F7036), 2));
    for (final p in [const Offset(22, 36), const Offset(32, 30), const Offset(42, 24)]) {
      c.drawCircle(p, 6, _fill(const Color(0xFFE6E0A8)));
      c.drawCircle(p, 6, _line(const Color(0xFFB9B36E), 1.4));
    }
    c.drawPath(Path()..moveTo(52, 14)..quadraticBezierTo(58, 8, 60, 4), _line(const Color(0xFF4F7036), 3));
  }

  void _almond(Canvas c) {
    for (final shift in [const Offset(-8, 4), const Offset(10, -2)]) {
      c.save();
      c.translate(32 + shift.dx, 32 + shift.dy);
      c.rotate(shift.dx < 0 ? -0.5 : 0.45);
      final nut = Path()
        ..moveTo(0, -22)
        ..quadraticBezierTo(15, -6, 10, 12)
        ..quadraticBezierTo(0, 24, -10, 12)
        ..quadraticBezierTo(-15, -6, 0, -22)
        ..close();
      c.drawPath(nut, _fill(const Color(0xFFC79A6B)));
      c.drawPath(nut, _line(const Color(0xFF7A5230), 2));
      c.drawPath(Path()..moveTo(0, -16)..quadraticBezierTo(5, 0, 0, 14), _line(const Color(0xFF9B7249), 1.6));
      c.restore();
    }
  }

  void _oat(Canvas c) {
    const gold = Color(0xFFD9B25A);
    c.drawPath(Path()..moveTo(32, 62)..quadraticBezierTo(30, 36, 32, 10), _line(const Color(0xFF8C9A4F), 3));
    for (var i = 0; i < 5; i++) {
      final y = 14.0 + i * 8;
      for (final s in [-1.0, 1.0]) {
        c.save();
        c.translate(32 + s * 2, y);
        c.rotate(s * 0.6);
        c.drawOval(Rect.fromCenter(center: Offset(s * 7, 0), width: 11, height: 5.6), _fill(gold));
        c.drawOval(Rect.fromCenter(center: Offset(s * 7, 0), width: 11, height: 5.6), _line(const Color(0xFF9B7A2E), 1));
        c.restore();
      }
    }
    c.drawOval(Rect.fromCenter(center: const Offset(32, 8), width: 6, height: 10), _fill(gold));
  }

  void _drop(Canvas c) {
    final drop = Path()
      ..moveTo(32, 8)
      ..quadraticBezierTo(52, 32, 46, 46)
      ..quadraticBezierTo(32, 62, 18, 46)
      ..quadraticBezierTo(12, 32, 32, 8)
      ..close();
    c.drawPath(drop, _fill(StudioColors.cream));
    c.drawPath(drop, _line(StudioColors.primary, 2.4));
    c.drawArc(const Rect.fromLTWH(22, 30, 16, 16), math.pi * 0.2, math.pi * 0.5, false, _line(StudioColors.latte, 2.2));
  }

  @override
  bool shouldRepaint(covariant MilkIllustrationPainter old) => old.kind != kind;
}
