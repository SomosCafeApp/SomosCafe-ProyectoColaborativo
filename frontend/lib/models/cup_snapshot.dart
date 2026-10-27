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
  final List<String> syrups;
  final int sweeteners;
  final String latteArt;

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
    this.syrups = const [],
    this.sweeteners = 0,
    this.latteArt = '',
  });

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
