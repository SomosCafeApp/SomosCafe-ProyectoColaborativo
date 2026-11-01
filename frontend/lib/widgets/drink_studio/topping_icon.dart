import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'studio_colors.dart';
import 'topping_painters.dart';

/// Ícono ilustrado de un topping. Cada ingrediente tiene el suyo
/// (crema, canela, chispas, caramelo, cacao, virutas, malvaviscos); solo
/// los nombres desconocidos usan un destello genérico.
class ToppingIcon extends StatelessWidget {
  const ToppingIcon({super.key, required this.name, this.size = 44});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
        image: true,
        label: name,
        child: ExcludeSemantics(child: CustomPaint(size: Size.square(size), painter: _ToppingPainter(name.toLowerCase()))),
      );
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
      // Hilo ondulado de caramelo que cae sobre la gota.
      canvas.drawPath(Path()..moveTo(4, 8)..quadraticBezierTo(10, 2, 15, 8)..quadraticBezierTo(20, 14, 26, 6), line(StudioColors.caramel, 2.2));
    } else if (n.contains('cacao') || n.contains('cocoa')) {
      // Colador con cacao cayendo y un montoncito de polvo.
      final bowl = Path()
        ..moveTo(8, 10)
        ..quadraticBezierTo(22, 24, 36, 10)
        ..close();
      canvas.drawPath(bowl, fill(const Color(0xFFD9C4A6)));
      canvas.drawPath(bowl, line(const Color(0xFF6B4B33), 1.6));
      canvas.drawLine(const Offset(36, 10), const Offset(41, 6), line(const Color(0xFF6B4B33), 2));
      final rnd = math.Random(9);
      for (var i = 0; i < 10; i++) {
        canvas.drawCircle(Offset(15 + rnd.nextDouble() * 14, 20 + rnd.nextDouble() * 10), 1.1, fill(const Color(0xFF4A2A18)));
      }
      final mound = Path()
        ..moveTo(8, 38)
        ..quadraticBezierTo(22, 24, 36, 38)
        ..close();
      canvas.drawPath(mound, fill(const Color(0xFF5A3522)));
      canvas.drawCircle(const Offset(19, 33), 1.3, fill(const Color(0xFF8A5A3A)));
      canvas.drawCircle(const Offset(26, 35), 1.1, fill(const Color(0xFF8A5A3A)));
    } else if (n.contains('viruta') || n.contains('shav') || n.contains('curl')) {
      // Rizos de chocolate: tiras enrolladas con el interior claro.
      for (final c in const [Offset(14, 28), Offset(28, 22), Offset(22, 12)]) {
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.rotate(c.dx * 0.07);
        final r = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 22, height: 9), const Radius.circular(4.5));
        canvas.drawRRect(r, fill(const Color(0xFF4A2A18)));
        canvas.drawRRect(r, line(const Color(0xFF2E1A0F), 1.2));
        canvas.drawOval(Rect.fromCenter(center: const Offset(-9, 0), width: 6, height: 8), fill(const Color(0xFFB8875C)));
        canvas.drawLine(const Offset(-5, -2), const Offset(7, -2), line(Colors.white.withValues(alpha: 0.35), 1));
        canvas.restore();
      }
    } else if (n.contains('malvavisco') || n.contains('marshmallow')) {
      for (final c in const [Offset(14, 28), Offset(30, 28), Offset(22, 15)]) {
        final i = c.dx.round() + c.dy.round();
        final body = RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: 16, height: 13), const Radius.circular(5.5));
        canvas.drawRRect(body, fill(i % 3 == 0 ? const Color(0xFFFBE3E8) : const Color(0xFFFFFDF8)));
        canvas.drawRRect(body, line(const Color(0xFFC9B89B), 1.3));
        canvas.drawArc(Rect.fromCenter(center: c.translate(0, -3), width: 11, height: 5), math.pi, math.pi, false, line(const Color(0xFFD7A25E).withValues(alpha: 0.8), 1.8));
      }
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

/// Cómo queda el topping sobre la bebida: un mini vaso visto desde arriba
/// pintado con el MISMO motor de toppings de la bebida real, así lo que
/// ves en la tarjeta es lo que verás en tu latte.
class ToppingSwatch extends StatelessWidget {
  const ToppingSwatch({super.key, required this.name, this.size = 34});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: RepaintBoundary(child: CustomPaint(size: Size.square(size), painter: _SwatchPainter(name))),
      );
}

class _SwatchPainter extends CustomPainter {
  _SwatchPainter(this.name);
  final String name;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 1;
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFFC79A6A));
    canvas.drawCircle(c, r, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = StudioColors.ink.withValues(alpha: 0.35));
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));
    ToppingPainters.paint(canvas, c, r * 0.9, r * 0.9, [name], const {}, hasArt: false, topView: true);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SwatchPainter old) => old.name != name;
}
