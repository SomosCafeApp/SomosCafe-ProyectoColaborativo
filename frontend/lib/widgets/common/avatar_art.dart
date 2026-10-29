import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Los cinco avatares predefinidos de SOMOS CAFÉ. Las claves deben
/// coincidir con backend/utils/avatars.js. Son dibujos vectoriales
/// propios (sin imágenes externas): livianos y nítidos a cualquier tamaño.
class AvatarPresets {
  AvatarPresets._();

  static const List<AvatarPreset> all = [
    AvatarPreset('grano', 'Grano de café'),
    AvatarPreset('taza', 'Taza'),
    AvatarPreset('barista', 'Barista'),
    AvatarPreset('latte', 'Latte art'),
    AvatarPreset('cafetera', 'Cafetera'),
  ];

  static bool isValid(String? key) => all.any((p) => p.key == key);

  static String nameOf(String key) =>
      all.firstWhere((p) => p.key == key, orElse: () => all.first).name;
}

class AvatarPreset {
  final String key;
  final String name;
  const AvatarPreset(this.key, this.name);
}

/// Dibuja el avatar predefinido [presetKey] dentro de un círculo de
/// lado [size].
class AvatarArt extends StatelessWidget {
  final String presetKey;
  final double size;

  const AvatarArt({super.key, required this.presetKey, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Avatar ${AvatarPresets.nameOf(presetKey)}',
      child: ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _AvatarPainter(presetKey)),
        ),
      ),
    );
  }
}

const _espresso = Color(0xFF3E2A20);
const _mocha = Color(0xFF9E6D41);
const _cream = Color(0xFFF6E9D7);
const _milk = Color(0xFFFFFBF5);

class _AvatarPainter extends CustomPainter {
  final String key_;
  _AvatarPainter(this.key_);

  @override
  void paint(Canvas canvas, Size size) {
    // Todo se dibuja en un cuadrado de 100 x 100 y se escala.
    canvas.scale(size.width / 100, size.height / 100);
    switch (key_) {
      case 'grano':
        _bean(canvas);
      case 'taza':
        _cup(canvas);
      case 'barista':
        _barista(canvas);
      case 'latte':
        _latte(canvas);
      case 'cafetera':
        _moka(canvas);
      default:
        canvas.drawRect(const Rect.fromLTWH(0, 0, 100, 100), Paint()..color = _cream);
    }
  }

  Paint _fill(Color c) => Paint()..color = c;

  Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round;

  void _bg(Canvas canvas, Color c) =>
      canvas.drawRect(const Rect.fromLTWH(0, 0, 100, 100), _fill(c));

  void _bean(Canvas canvas) {
    _bg(canvas, const Color(0xFFF1DFC8));
    canvas.save();
    canvas.translate(50, 50);
    canvas.rotate(-math.pi / 5);
    canvas.drawOval(const Rect.fromLTWH(-24, -33, 48, 66), _fill(_espresso));
    canvas.drawOval(const Rect.fromLTWH(-17, -28, 12, 26), _fill(const Color(0x22FFFFFF)));
    final crease = Path()
      ..moveTo(0, -30)
      ..cubicTo(-14, -14, 14, 14, 0, 30);
    canvas.drawPath(crease, _stroke(const Color(0xFFF1DFC8), 4.5));
    canvas.restore();
  }

  void _cup(Canvas canvas) {
    _bg(canvas, const Color(0xFFE6CFB4));
    // vapor
    final steam = Path()
      ..moveTo(40, 30)
      ..cubicTo(34, 24, 46, 20, 40, 13)
      ..moveTo(54, 30)
      ..cubicTo(48, 24, 60, 20, 54, 13);
    canvas.drawPath(steam, _stroke(_mocha, 3));
    // asa
    canvas.drawArc(const Rect.fromLTWH(62, 42, 20, 22), -math.pi / 2, math.pi, false, _stroke(_milk, 5));
    // cuerpo
    final body = Path()
      ..moveTo(26, 38)
      ..lineTo(70, 38)
      ..lineTo(66, 64)
      ..quadraticBezierTo(64, 76, 48, 76)
      ..quadraticBezierTo(32, 76, 30, 64)
      ..close();
    canvas.drawPath(body, _fill(_milk));
    canvas.drawOval(const Rect.fromLTWH(26, 33, 44, 10), _fill(_espresso));
    // plato
    canvas.drawOval(const Rect.fromLTWH(22, 74, 52, 9), _fill(_mocha));
  }

  void _barista(Canvas canvas) {
    _bg(canvas, _mocha);
    // delantal / hombros
    final shoulders = Path()
      ..moveTo(14, 100)
      ..quadraticBezierTo(16, 72, 50, 70)
      ..quadraticBezierTo(84, 72, 86, 100)
      ..close();
    canvas.drawPath(shoulders, _fill(_milk));
    canvas.drawRect(const Rect.fromLTWH(44, 72, 12, 28), _fill(_espresso));
    // cara
    canvas.drawCircle(const Offset(50, 46), 19, _fill(const Color(0xFFF0C7A0)));
    // gorro
    final cap = Path()
      ..moveTo(30, 40)
      ..quadraticBezierTo(50, 16, 70, 40)
      ..lineTo(70, 36)
      ..quadraticBezierTo(50, 8, 30, 36)
      ..close();
    canvas.drawPath(cap, _fill(_espresso));
    canvas.drawRect(const Rect.fromLTWH(30, 34, 40, 6), _fill(_espresso));
    // rostro
    canvas.drawCircle(const Offset(43, 48), 1.9, _fill(_espresso));
    canvas.drawCircle(const Offset(57, 48), 1.9, _fill(_espresso));
    canvas.drawArc(const Rect.fromLTWH(43, 51, 14, 9), 0.2, math.pi - 0.4, false, _stroke(_espresso, 2));
  }

  void _latte(Canvas canvas) {
    _bg(canvas, const Color(0xFFD8B994));
    canvas.drawCircle(const Offset(50, 50), 36, _fill(_milk));
    canvas.drawCircle(const Offset(50, 50), 29, _fill(_mocha));
    // corazón de espuma
    final heart = Path()
      ..moveTo(50, 66)
      ..cubicTo(30, 52, 36, 34, 50, 43)
      ..cubicTo(64, 34, 70, 52, 50, 66)
      ..close();
    canvas.drawPath(heart, _fill(_cream));
    canvas.drawLine(const Offset(50, 46), const Offset(50, 63), _stroke(_mocha, 2));
  }

  void _moka(Canvas canvas) {
    _bg(canvas, const Color(0xFFEBDDC9));
    const metal = Color(0xFFB9B1A9);
    // base
    final base = Path()
      ..moveTo(32, 80)
      ..lineTo(68, 80)
      ..lineTo(64, 56)
      ..lineTo(36, 56)
      ..close();
    canvas.drawPath(base, _fill(metal));
    // cintura
    canvas.drawRect(const Rect.fromLTWH(37, 50, 26, 7), _fill(_espresso));
    // parte superior
    final top = Path()
      ..moveTo(36, 50)
      ..lineTo(64, 50)
      ..lineTo(60, 26)
      ..lineTo(40, 26)
      ..close();
    canvas.drawPath(top, _fill(metal));
    // tapa + perilla
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(38, 21, 24, 6), const Radius.circular(3)), _fill(_espresso));
    canvas.drawCircle(const Offset(50, 18), 3.5, _fill(_espresso));
    // pico y asa
    canvas.drawLine(const Offset(40, 27), const Offset(34, 30), _stroke(_espresso, 3));
    canvas.drawArc(const Rect.fromLTWH(60, 26, 18, 30), -math.pi / 2, math.pi, false, _stroke(_espresso, 5));
    // brillo
    canvas.drawLine(const Offset(42, 60), const Offset(44, 76), _stroke(const Color(0x66FFFFFF), 3));
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter old) => old.key_ != key_;
}
