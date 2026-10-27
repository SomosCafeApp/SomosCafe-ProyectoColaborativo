import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'studio_colors.dart';

/// Ícono ilustrado de un topping (crema, canela, chispas, caramelo...).
/// Para nombres desconocidos usa un destello genérico.
class ToppingIcon extends StatelessWidget {
  const ToppingIcon({super.key, required this.name, this.size = 44});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _ToppingPainter(name.toLowerCase()));
}

class _ToppingPainter extends CustomPainter {
  _ToppingPainter(this.n);
  final String n;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 44);
    Paint fill(Color c) => Paint()..color = c;
    Paint line(Color c, double w) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w
      ..color = c;

    if (n.contains('crema') || n.contains('whip')) {
      for (var i = 0; i < 3; i++) {
        final w = 30.0 - i * 8, y = 32.0 - i * 9;
        final r = Rect.fromCenter(center: Offset(22, y), width: w, height: 11);
        canvas.drawOval(r, fill(StudioColors.cream));
        canvas.drawOval(r, line(StudioColors.latte, 1.6));
      }
      canvas.drawPath(Path()..moveTo(22, 6)..quadraticBezierTo(26, 9, 22, 12), fill(StudioColors.cream));
    } else if (n.contains('canela') || n.contains('cinn')) {
      for (final dy in [-4.0, 4.0]) {
        canvas.save();
        canvas.translate(22, 22 + dy);
        canvas.rotate(-0.5 + dy * 0.03);
        final r = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 34, height: 9), const Radius.circular(5));
        canvas.drawRRect(r, fill(const Color(0xFFA0603A)));
        canvas.drawRRect(r, line(const Color(0xFF6B3A1F), 1.4));
        canvas.drawLine(const Offset(-14, 0), const Offset(14, 0), line(const Color(0xFF6B3A1F), 1));
        canvas.restore();
      }
    } else if (n.contains('chispa') || n.contains('chip') || n.contains('sprinkle')) {
      const colors = [Color(0xFF3B2416), Color(0xFFF3E2C3), Color(0xFFB5793F), Color(0xFFD08A2E)];
      final rnd = math.Random(4);
      for (var i = 0; i < 11; i++) {
        canvas.save();
        canvas.translate(7 + rnd.nextDouble() * 30, 8 + rnd.nextDouble() * 28);
        canvas.rotate(rnd.nextDouble() * math.pi);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 9, height: 4), const Radius.circular(2)), fill(colors[i % 4]));
        canvas.restore();
      }
    } else if (n.contains('caramel')) {
      final drop = Path()
        ..moveTo(22, 6)
        ..quadraticBezierTo(34, 22, 30, 30)
        ..quadraticBezierTo(22, 40, 14, 30)
        ..quadraticBezierTo(10, 22, 22, 6)
        ..close();
      canvas.drawPath(drop, fill(StudioColors.caramel));
      canvas.drawPath(drop, line(const Color(0xFF8C5C2B), 1.6));
      canvas.drawCircle(const Offset(18, 26), 2.6, fill(Colors.white.withValues(alpha: 0.6)));
    } else {
      final star = Path();
      for (var i = 0; i < 8; i++) {
        final a = i * math.pi / 4 - math.pi / 2;
        final r = i.isEven ? 16.0 : 6.0;
        final p = Offset(22 + math.cos(a) * r, 22 + math.sin(a) * r);
        i == 0 ? star.moveTo(p.dx, p.dy) : star.lineTo(p.dx, p.dy);
      }
      star.close();
      canvas.drawPath(star, fill(StudioColors.latte));
      canvas.drawPath(star, line(StudioColors.ink, 1.4));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ToppingPainter old) => old.n != n;
}
