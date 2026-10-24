/// Precio en pesos con separador de miles: 12500 → "$12.500".
String formatCop(double value) {
  final digits = value.round().abs().toString();
  final dotted = digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
  return '${value < 0 ? '-' : ''}\$$dotted';
}

/// Diferencia de precio de una opción: "Incluido" o "+$3.000".
String formatExtra(double value) => value <= 0 ? 'Incluido' : '+${formatCop(value)}';
