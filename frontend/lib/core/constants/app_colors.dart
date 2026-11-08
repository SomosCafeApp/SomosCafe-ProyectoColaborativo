import 'package:flutter/material.dart';

class AppColors {
  // Marca / Primarios
  static const Color primary = Color(0xFF9E6D41);        // Café Moca Medio
  static const Color accentYellow = Color(0xFFFFC107);   // Amarillo Descuento

  // MODO CLARO
  static const Color lightBackground = Color(0xFFFAF7F2);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSubtle = Color(0xFFF7F2EB);
  static const Color lightTextPrimary = Color(0xFF2B221E);
  static const Color lightTextSecondary = Color(0xFF8A7E75);

  // MODO OSCURO: misma familia moca, con más profundidad. Cada capa
  // (fondo → tarjeta → tarjeta secundaria → elevado) sube un escalón de
  // luminosidad para que las tarjetas se distingan sin usar bordes blancos.
  static const Color darkBackground = Color(0xFF120B08);   // Fondo principal, espresso profundo
  static const Color darkSurface = Color(0xFF211610);      // Tarjetas
  static const Color darkSurfaceSubtle = Color(0xFF302219); // Campos y tarjetas secundarias
  static const Color darkSurfaceRaised = Color(0xFF3B2B20); // Elementos elevados / seleccionados
  static const Color darkBorder = Color(0xFF42322A);       // Línea tonal (café, nunca blanca)
  static const Color darkTextPrimary = Color(0xFFFBF6EF);
  static const Color darkTextSecondary = Color(0xFFCDBFB3);
  static const Color darkAccent = Color(0xFFD9A877);       // Caramelo claro: acentos y enlaces legibles sobre oscuro

  // Categorías
  static const Color catWarm = Color(0xFFFDF0D5);
  static const Color catCold = Color(0xFFE0F2FE);
  static const Color catSweet = Color(0xFFFCE7F3);
}