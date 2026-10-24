import 'package:flutter/material.dart';

/// Foto inmutable de lo que lleva el vaso en este momento. La pinta
/// `TakeawayCupPainter`; el provider la arma con las elecciones reales.
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
  final double mix;
  final List<String> toppings;
  final List<String> syrups;
  final int sweeteners;
  final String latteArt;

  /// Profundidad de la cuchara (0..1) o null si no se está mezclando.
  final double? spoon;

  const CupSnapshot({
    this.sizeFactor = 1,
    this.ounces,
    this.isHot = true,
    this.isCoffee = true,
    this.baseColor = const Color(0xFF4A2C1B),
    this.shots = 0,
    this.milkLevel = 0,
    this.milkColor = const Color(0xFFF7EEDC),
    this.mix = 0,
    this.toppings = const [],
    this.syrups = const [],
    this.sweeteners = 0,
    this.latteArt = '',
    this.spoon,
  });
}

/// Efecto de "verter" que se anima sobre el vaso al tocar una opción.
enum PourKind { none, espresso, milk, syrup, sweetener, topping }
