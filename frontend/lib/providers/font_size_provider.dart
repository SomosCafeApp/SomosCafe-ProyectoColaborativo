import 'package:flutter/material.dart';

class FontSizeProvider extends ChangeNotifier {
  String _fontSize = 'Mediano';

  String get fontSize => _fontSize;

  // Factor de escala que se aplica a TODO el texto de la app
  // mediante el MediaQuery del MaterialApp (ver main.dart).
  double get scaleFactor {
    switch (_fontSize) {
      case 'Pequeño':
        return 0.85;
      case 'Grande':
        return 1.25;
      case 'Mediano':
      default:
        return 1.0;
    }
  }

  void setFontSize(String value) {
    if (_fontSize == value) return;
    _fontSize = value;
    notifyListeners();
  }
}