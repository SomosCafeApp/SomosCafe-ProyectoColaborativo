import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Colores y rótulo del sobre de cada endulzante.
class SweetenerStyle {
  const SweetenerStyle({required this.paper, required this.accent, required this.ink, required this.label});

  /// Color del papel del sobre.
  final Color paper;

  /// Franja central con el nombre.
  final Color accent;

  /// Contorno y texto.
  final Color ink;
  final String label;

  static SweetenerStyle of(String name) {
    final n = name.toLowerCase();
    if (n.contains('morena') || n.contains('brown')) {
      return const SweetenerStyle(paper: Color(0xFFE9D2B0), accent: Color(0xFF9A6A3A), ink: Color(0xFF5A3A20), label: 'MORENA');
    }
    if (n.contains('estevia') || n.contains('stevia')) {
      return const SweetenerStyle(paper: Color(0xFFF1F7EA), accent: Color(0xFF4E9A52), ink: Color(0xFF2F6B35), label: 'ESTEVIA');
    }
    if (n.contains('panela')) {
      return const SweetenerStyle(paper: Color(0xFFEBC590), accent: Color(0xFFB8651F), ink: Color(0xFF6B3A12), label: 'PANELA');
    }
    if (n.contains('miel') || n.contains('honey')) {
      return const SweetenerStyle(paper: Color(0xFFFBE8A8), accent: Color(0xFFE0A020), ink: Color(0xFF7A5410), label: 'MIEL');
    }
    if (n.contains('blanca') || n.contains('white') || n.contains('azúcar') || n.contains('azucar')) {
      return const SweetenerStyle(paper: Color(0xFFFFFFFF), accent: Color(0xFF4A86C5), ink: Color(0xFF2E5C8E), label: 'AZÚCAR');
    }
    return const SweetenerStyle(paper: Color(0xFFFFF6E6), accent: Color(0xFF9E6D41), ink: Color(0xFF5A3A24), label: 'DULCE');
  }
}

/// Dibuja el sobre individual de un endulzante (bordes dentados arriba
/// y abajo, franja con el nombre). Lo usan los pintores del vaso, la
/// vista desde arriba y las tarjetas de la interfaz.
class SweetenerPacketPainter {
  SweetenerPacketPainter._();

  /// Proporción alto / ancho de un sobre.
  static const double aspect = 1.55;

  static Path _crimped(Rect b) {
    const teeth = 8;
    final step = b.width / teeth;
    final d = b.height * 0.04;
    final path = Path()..moveTo(b.left, b.top + d);
    for (var i = 0; i < teeth; i++) {
      path
        ..lineTo(b.left + step * (i + 0.5), b.top)
        ..lineTo(b.left + step * (i + 1), b.top + d);
    }
    path.lineTo(b.right, b.bottom - d);
    for (var i = 0; i < teeth; i++) {
      path
        ..lineTo(b.right - step * (i + 0.5), b.bottom)
        ..lineTo(b.right - step * (i + 1), b.bottom - d);
    }
    return path..close();
  }

  /// Sobre de ancho [width] centrado en [center], girado [angle] radianes.
  static void paint(Canvas canvas, Offset center, double width, String name, {double angle = 0, bool shadow = true}) {
    final st = SweetenerStyle.of(name);
    final w = width, h = width * aspect;
    final body = Rect.fromCenter(center: Offset.zero, width: w, height: h);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    if (shadow) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(body.shift(Offset(w * 0.07, h * 0.045)), Radius.circular(w * 0.08)),
        Paint()..color = Colors.black.withValues(alpha: 0.18),
      );
    }

    final path = _crimped(body);
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color.lerp(st.paper, Colors.white, 0.4)!, st.paper, Color.lerp(st.paper, Colors.black, 0.14)!],
          stops: const [0, 0.55, 1],
        ).createShader(body),
    );

    canvas.save();
    canvas.clipPath(path);
    // Franja de color con el nombre.
    final band = Rect.fromLTWH(body.left, body.top + h * 0.33, w, h * 0.3);
    canvas.drawRect(band, Paint()..color = st.accent);
    canvas.drawRect(Rect.fromLTWH(body.left, band.top, w, h * 0.012), Paint()..color = Colors.white.withValues(alpha: 0.4));
    // Brillo vertical del plástico.
    canvas.drawRect(Rect.fromLTWH(body.left + w * 0.13, body.top, w * 0.09, h), Paint()..color = Colors.white.withValues(alpha: 0.28));
    // Costura central de las dos aletas.
    canvas.drawLine(
      Offset(body.left, body.top + h * 0.075),
      Offset(body.right, body.top + h * 0.075),
      Paint()
        ..strokeWidth = math.max(0.8, w * 0.018)
        ..color = st.ink.withValues(alpha: 0.25),
    );
    canvas.restore();

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = math.max(1.0, w * 0.035)
        ..color = st.ink.withValues(alpha: 0.6),
    );

    if (w >= 26) {
      final tp = TextPainter(
        text: TextSpan(
          text: st.label,
          style: TextStyle(color: Colors.white, fontSize: w * 0.2, fontWeight: FontWeight.w900, letterSpacing: w * 0.012),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: w * 0.92);
      tp.paint(canvas, Offset(-tp.width / 2, band.center.dy - tp.height / 2));
    }
    canvas.restore();
  }

  /// Sobres de [names] apoyados en abanico: el primero es el de más
  /// atrás. [origin] es el centro del sobre del frente.
  static void paintFan(Canvas canvas, Offset origin, double width, List<String> names, {double spread = 0.78}) {
    for (var i = 0; i < names.length; i++) {
      final back = names.length - 1 - i;
      final angle = 0.16 + 0.1 * i - (names.length - 1) * 0.05;
      paint(canvas, origin.translate(-back * width * spread, -back * width * 0.08), width, names[i], angle: angle);
    }
  }
}

/// Miniatura del sobre para tarjetas y resúmenes.
class SweetenerPacket extends StatelessWidget {
  const SweetenerPacket({super.key, required this.name, this.width = 40, this.angle = 0});
  final String name;
  final double width;
  final double angle;

  @override
  Widget build(BuildContext context) {
    final h = width * SweetenerPacketPainter.aspect;
    return SizedBox(
      width: width * 1.25,
      height: h * 1.12,
      child: CustomPaint(painter: _PacketWidgetPainter(name, width, angle)),
    );
  }
}

class _PacketWidgetPainter extends CustomPainter {
  _PacketWidgetPainter(this.name, this.width, this.angle);
  final String name;
  final double width;
  final double angle;

  @override
  void paint(Canvas canvas, Size size) => SweetenerPacketPainter.paint(canvas, size.center(Offset.zero), width, name, angle: angle);

  @override
  bool shouldRepaint(covariant _PacketWidgetPainter old) => old.name != name || old.width != width || old.angle != angle;
}
