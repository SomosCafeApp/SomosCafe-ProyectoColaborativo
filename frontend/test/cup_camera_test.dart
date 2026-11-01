import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:somoscafeapp/models/cup_snapshot.dart';
import 'package:somoscafeapp/widgets/drink_studio/ambient_painter.dart';
import 'package:somoscafeapp/widgets/drink_studio/art_pour.dart';
import 'package:somoscafeapp/widgets/drink_studio/cup_geometry.dart';
import 'package:somoscafeapp/widgets/drink_studio/milk_badge.dart';
import 'package:somoscafeapp/widgets/drink_studio/takeaway_cup_painter.dart';
import 'package:somoscafeapp/widgets/drink_studio/topping_painters.dart';
import 'package:flutter/material.dart';

const size = Size(380, 460);

CupSnapshot snap({bool hot = true, List<String> toppings = const [], String art = ''}) => CupSnapshot(
      sizeFactor: 1,
      ounces: 12,
      isHot: hot,
      isCoffee: true,
      baseColor: const Color(0xFF4A2A18),
      shots: 1,
      milkLevel: 0.55,
      milkColor: const Color(0xFFC79A6A),
      toppings: toppings,
      toppingQty: const {},
      syrups: const [],
      sweeteners: const [],
      latteArt: art,
      label: 'Latte',
    );

void main() {
  group('cámara continua', () {
    test('en reposo el vaso apoya abajo y la boca es una elipse', () {
      final g = CupGeo(size, 1);
      expect(g.rimRy, lessThan(g.rimRx));
      expect(g.topY, greaterThan(size.height * 0.3));
    });

    test('en vista cenital la boca es un círculo en el centro', () {
      final g = CupGeo(size, 1, tilt: 1, top: 1);
      expect(g.rimRy, closeTo(g.rimRx, 0.001));
      expect(g.cx, closeTo(size.width / 2, 0.001));
      expect(g.topY, closeTo(size.height / 2, 0.001));
    });

    test('la cámara de lado → arriba no tiene saltos', () {
      double? px, py, pw;
      for (var i = 0; i <= 100; i++) {
        final cam = i / 100;
        final tilt = (cam / 0.5).clamp(0.0, 1.0);
        final top = ((cam - 0.5) / 0.5).clamp(0.0, 1.0);
        final g = CupGeo(size, 1, tilt: tilt, top: top);
        if (px != null) {
          expect((g.cx - px).abs(), lessThan(5));
          expect((g.topY - py!).abs(), lessThan(14));
          expect((g.topW - pw!).abs(), lessThan(14));
        }
        px = g.cx;
        py = g.topY;
        pw = g.topW;
      }
    });

    test('la superficie visible se mantiene dentro de la boca', () {
      for (final top in [0.0, 0.5, 1.0]) {
        final g = CupGeo(size, 1, tilt: 1, top: top);
        final (c, rx, ry) = g.visibleSurface(0.8);
        expect(rx, lessThanOrEqualTo(g.rimRx));
        expect(ry, lessThanOrEqualTo(g.rimRy + 0.01));
        expect(c.dx, closeTo(g.cx, 0.01));
      }
    });
  });

  group('los pintores no fallan en ningún estado', () {
    void paintAll(void Function(Canvas) body) {
      final rec = PictureRecorder();
      body(Canvas(rec));
      rec.endRecording();
    }

    test('vaso: cámara × temperatura × toppings × calidad', () {
      for (final hot in [true, false]) {
        for (final tilt in [0.0, 0.5, 1.0]) {
          for (final top in [0.0, 0.4, 1.0]) {
            for (final q in [0.5, 1.0]) {
              paintAll((c) => TakeawayCupPainter(
                    snap: snap(hot: hot, toppings: hot ? ['Crema batida', 'Canela', 'Malvaviscos'] : ['Caramelo', 'Chispas'], art: hot ? 'Corazón' : ''),
                    time: 3.2,
                    cold: hot ? 0 : 1,
                    tilt: tilt,
                    top: top,
                    quality: q,
                    toppingProgress: const {'Canela': 0.4, 'Crema batida': 0.7},
                    dark: false,
                    effect: PourKind.none,
                    effectT: 0,
                    effectSeed: 0,
                    lid: 0,
                    scene: const ArtScene(),
                  ).paint(c, size));
            }
          }
        }
      }
    });

    test('toppings: todos, en cada avance y en ambas vistas', () {
      const all = ['Crema batida', 'Canela', 'Chispas', 'Caramelo', 'Cacao en polvo', 'Virutas de chocolate', 'Malvaviscos'];
      for (final top in [false, true]) {
        for (final p in [0.0, 0.01, 0.3, 0.6, 0.99, 1.0]) {
          for (final name in all) {
            paintAll((c) => ToppingPainters.paint(c, const Offset(100, 100), 80, 60, [name], const {}, hasArt: false, topView: top, progress: {name: p}));
          }
        }
      }
    });

    test('vapor, partículas, contorno y cartón', () {
      paintAll((c) {
        SteamField.paint(c, origin: const Offset(190, 200), width: 120, height: 160, time: 5, strength: 1, dark: false);
        SteamField.paint(c, origin: const Offset(190, 200), width: 120, height: 160, time: 5, strength: 0.4, dark: true, quality: 0.5, spread: 1);
        for (final m in [0.0, 0.3, 0.5, 0.8, 1.0]) {
          ThermalParticle.paint(c, const Offset(50, 50), 5, m, 0.8, 1.2, 2.0, false);
        }
        for (final cold in [0.0, 0.5, 1.0]) {
          ThermalOutline.stroke(c, Path()..addOval(const Rect.fromLTWH(40, 40, 200, 100)), const Rect.fromLTWH(40, 40, 200, 100), cold: cold, time: 1);
        }
        AmbientPainter(time: 4, cold: 0.5, front: true, dark: false).paint(c, size);
        for (final t in [0.0, 0.1, 0.3, 0.5, 0.7, 0.9, 0.99]) {
          for (final kind in MilkKind.values) {
            MilkPourPainter(t: t, kind: kind, snap: snap()).paint(c, size);
          }
        }
      });
    });
  });

  test('el contorno pasa de cálido a frío de forma continua', () {
    final a = ThermalOutline.tone(0, 1);
    final b = ThermalOutline.tone(1, 1);
    final mid = ThermalOutline.tone(0.5, 1);
    expect(a, isNot(b));
    expect(mid.r, inInclusiveRange(b.r < a.r ? b.r : a.r, b.r < a.r ? a.r : b.r));
  });
}
