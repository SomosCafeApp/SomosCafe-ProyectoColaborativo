import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Foto inmutable de lo que lleva el vaso en este momento. La pintan
/// `TakeawayCupPainter` (de lado / inclinado) y `TopViewPainter`
/// (desde arriba); el provider la arma con las elecciones reales.
class CupSnapshot {
  /// Factor de escala del vaso (alto Y ancho) según las onzas: el
  /// volumen crece con el cubo de este factor.
  final double sizeFactor;
  final int? ounces;
  final bool isHot;
  final bool isCoffee;
  final Color baseColor;
  final int shots;
  final double milkLevel;
  final Color milkColor;
  final List<String> toppings;

  /// Porciones de cada topping (ausente = 1). Más porciones = más
  /// volumen de crema, más chispas, más hilos de caramelo...
  final Map<String, int> toppingQty;
  final List<String> syrups;

  /// Endulzantes elegidos: cada uno se dibuja como un sobre junto a la taza.
  final List<String> sweeteners;
  final String latteArt;

  /// Nombre impreso en la etiqueta del vaso.
  final String label;

  const CupSnapshot({
    this.sizeFactor = 1,
    this.ounces,
    this.isHot = true,
    this.isCoffee = true,
    this.baseColor = const Color(0xFF4A2C1B),
    this.shots = 0,
    this.milkLevel = 0,
    this.milkColor = const Color(0xFFF7EEDC),
    this.toppings = const [],
    this.toppingQty = const {},
    this.syrups = const [],
    this.sweeteners = const [],
    this.latteArt = '',
    this.label = '',
  });

  /// Misma bebida con otro tamaño (para animar el cambio de tamaño).
  CupSnapshot withSizeFactor(double factor) => CupSnapshot(
        sizeFactor: factor,
        ounces: ounces,
        isHot: isHot,
        isCoffee: isCoffee,
        baseColor: baseColor,
        shots: shots,
        milkLevel: milkLevel,
        milkColor: milkColor,
        toppings: toppings,
        toppingQty: toppingQty,
        syrups: syrups,
        sweeteners: sweeteners,
        latteArt: latteArt,
        label: label,
      );

  /// Porciones de [name] (mínimo 1 si está elegido).
  int qtyOf(String name) => toppings.contains(name) ? (toppingQty[name] ?? 1).clamp(1, 9).toInt() : 0;

  /// Qué tan lleno está el vaso (0..1): base de café + leche.
  double get fill {
    final baseFrac = isCoffee ? math.min(0.16 + 0.055 * shots, 0.46) : 0.5;
    final milkFrac = math.max(0.0, math.min(milkLevel * 0.62, 0.9 - baseFrac));
    return (baseFrac + milkFrac).clamp(0.0, 1.0).toDouble();
  }

  /// Color de la superficie de la bebida (leche sobre base).
  Color get surfaceColor => Color.lerp(milkLevel > 0.02 ? milkColor : baseColor, Colors.white, 0.1)!;
}

/// Efecto de "verter" que se anima sobre el vaso al tocar una opción.
enum PourKind { none, espresso, milk, syrup, sweetener, topping }

/// Cómo se ve el vaso en cada sección.
enum CupView { side, tilt, top }

/// Animación al cambiar de sección: el vaso se desplaza y, según el
/// paso, aparecen un copo y una llama (tempIntro) o un estallido de
/// hielo o fuego (tempBurst).
enum StudioTransition { none, plain, tempIntro, tempBurst }
