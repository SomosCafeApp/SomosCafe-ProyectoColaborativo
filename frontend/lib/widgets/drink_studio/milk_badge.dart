import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'studio_colors.dart';

/// Ilustración breve que aparece al elegir una leche: vaca (entera),
/// soya, almendra o planta de avena. Si el nombre no coincide con
/// ninguna, muestra una gota genérica (no se inventa un origen).
enum MilkKind { cow, soy, almond, oat, generic }

MilkKind milkKindOf(String name) {
  final n = name.toLowerCase();
  if (n.contains('entera') || n.contains('vaca') || n.contains('deslact')) return MilkKind.cow;
  if (n.contains('soya') || n.contains('soja')) return MilkKind.soy;
  if (n.contains('almendra')) return MilkKind.almond;
  if (n.contains('avena')) return MilkKind.oat;
  return MilkKind.generic;
}

/// Burbuja que aparece con un rebote y se desvanece sola (~1.5 s).
/// Se dispara cada vez que [tick] cambia.
class MilkBadge extends StatefulWidget {
  const MilkBadge({super.key, required this.tick, required this.name});
  final int tick;
  final String name;

  @override
  State<MilkBadge> createState() => _MilkBadgeState();
}

class _MilkBadgeState extends State<MilkBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  @override
  void didUpdateWidget(MilkBadge old) {
    super.didUpdateWidget(old);
    if (old.tick != widget.tick) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          if (t == 0 || t == 1) return const SizedBox.shrink();
          final pop = Curves.elasticOut.transform((t / 0.35).clamp(0.0, 1.0));
          final fade = t > 0.75 ? 1 - (t - 0.75) / 0.25 : 1.0;
          return Opacity(
            opacity: fade.clamp(0.0, 1.0).toDouble(),
            child: Transform.translate(
              offset: Offset(0, -18 * t),
              child: Transform.scale(
                scale: 0.3 + 0.7 * pop,
                child: Container(
                  width: 96,
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                  decoration: BoxDecoration(
                    color: StudioColors.panel(dark),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: StudioColors.primary, width: 1.6),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 12, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 64, height: 64, child: CustomPaint(painter: MilkIllustrationPainter(milkKindOf(widget.name)))),
                      const SizedBox(height: 4),
                      Text(widget.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: StudioColors.text(dark))),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
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
