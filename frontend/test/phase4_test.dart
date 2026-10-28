import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:somoscafeapp/core/utils/image_picking.dart';
import 'package:somoscafeapp/models/drink_options.dart';
import 'package:somoscafeapp/models/product_customization.dart';

/// Pruebas de la Fase 4: los precios de la app deben coincidir al centavo
/// con los del backend (backend/tests/pricing.test.js usa los mismos casos),
/// las reglas de toppings deben ser las del servidor y la selección de
/// imágenes debe manejar nombres, pesos y permisos.
void main() {
  group('Precios iguales al backend', () {
    double unit(double base, ProductCustomization c) => base + c.extraPriceFor(base);

    test('piso del tamaño Pequeño', () {
      expect(ProductCustomization.sizeAdjustment('Pequeño', 3500), -2500);
      expect(ProductCustomization.sizeAdjustment('Pequeño', 1000), 0);
      expect(ProductCustomization.sizeAdjustment('Pequeño', 500), 0);
      expect(ProductCustomization.sizeAdjustment('Pequeño', 8000), -3000);
      expect(ProductCustomization.sizeAdjustment('Grande', 500), 5000);
    });

    test('total final en varios productos', () {
      expect(
        unit(
          9500,
          ProductCustomization(
            size: 'Grande',
            milk: 'Avena',
            extraShots: 2,
            toppings: {'Crema batida', 'Canela'},
            toppingQuantities: {'Crema batida': 1, 'Canela': 2},
          ),
        ),
        9500 + 5000 + 1000 + 6000 + 2000 + (1000 + 300),
      );
      expect(unit(9500, ProductCustomization(size: 'Pequeño', milk: 'Soya', extraShots: 1)), 9500 - 3000 + 2000 + 3000);
      expect(unit(3500, ProductCustomization(size: 'Pequeño', toppings: {'Caramelo'})), 1000 + 1500);
      expect(unit(2000, ProductCustomization(size: 'Pequeño', extraShots: 1)), 1000 + 3000);
      expect(unit(12000, ProductCustomization()), 12000);
      expect(unit(800, ProductCustomization(size: 'Grande')), 800 + 5000);
    });

    test('Pequeño <= Mediano < Grande con cualquier precio base', () {
      for (final base in [500.0, 1000.0, 2500.0, 3500.0, 6000.0, 9500.0, 15000.0]) {
        final s = unit(base, ProductCustomization(size: 'Pequeño'));
        final m = unit(base, ProductCustomization());
        final g = unit(base, ProductCustomization(size: 'Grande'));
        expect(s <= m, isTrue, reason: 'base $base');
        expect(m < g, isTrue, reason: 'base $base');
        expect(s >= (base < 1000 ? base : 1000), isTrue, reason: 'base $base');
      }
    });

    test('la promoción nunca deja la unidad por debajo de \$0', () {
      final q = ProductCustomization(size: 'Pequeño').quote(
        basePrice: 3500,
        effectivePrice: 1750, // 50 % de descuento sobre el precio base
        promotionName: 'Promo',
      );
      expect(q.originalUnitPrice, 1000);
      expect(q.discountPerUnit, 1000);
      expect(q.unitPrice, 0);
      expect(q.unitPrice >= 0, isTrue);
    });
  });

  group('Compatibilidad de toppings (reglas del servidor)', () {
    const chocolate = ['chocolate', 'moca', 'mocha', 'cacao'];
    const milkCoffee = [
      'latte', 'capuch', 'cappuc', 'moca', 'mocha', 'macchiato', 'flat white', 'cortado',
      'con leche', 'frappe', 'frappé', 'malteada', 'batido', 'chocolate',
    ];
    const cacao = ToppingRule(keywords: milkCoffee);
    const virutas = ToppingRule(keywords: [...milkCoffee, ...chocolate]);
    const malvaviscos = ToppingRule(types: ['Caliente'], keywords: [...chocolate, 'latte']);

    test('cacao y virutas: con leche o chocolate; no en americano ni limonada', () {
      for (final rule in [cacao, virutas]) {
        expect(rule.allows(text: 'latte de vainilla hot drinks', type: 'Caliente'), isTrue);
        expect(rule.allows(text: 'frappé de caramelo cold drinks', type: 'Frío'), isTrue);
        expect(rule.allows(text: 'americano hot drinks', type: 'Caliente'), isFalse);
        expect(rule.allows(text: 'limonada de coco cold drinks', type: 'Frío'), isFalse);
      }
    });

    test('malvaviscos: solo calientes de chocolate o latte', () {
      expect(malvaviscos.allows(text: 'chocolate caliente hot drinks', type: 'Caliente'), isTrue);
      expect(malvaviscos.allows(text: 'chocolate caliente hot drinks', type: 'Frío'), isFalse);
      expect(malvaviscos.allows(text: 'capuchino hot drinks', type: 'Caliente'), isFalse);
      expect(malvaviscos.allows(text: 'americano hot drinks', type: 'Caliente'), isFalse);
    });

    test('ToppingRule.fromJson lee las reglas que publica el backend', () {
      final rule = ToppingRule.fromJson({
        'types': ['Caliente'],
        'keywords': ['Latte', 'Moca'],
      });
      expect(rule.types, ['Caliente']);
      expect(rule.keywords, ['latte', 'moca']);
      expect(ToppingRule.fromJson(null).allows(text: 'cualquiera', type: 'Frío'), isTrue);
    });
  });

  group('Selección de imágenes', () {
    Uint8List bytes(int n) => Uint8List.fromList(List.filled(n, 1));

    test('agrega extensión cuando la cámara no la entrega', () async {
      final warnings = <String>[];
      final img = await pickedImageFromFile(
        XFile.fromData(bytes(10), name: 'image_picker_123'),
        onWarning: warnings.add,
      );
      expect(img, isNotNull);
      expect(img!.name, 'image_picker_123.jpg');
      expect(warnings, isEmpty);
    });

    test('conserva extensiones válidas y reemplaza las raras', () async {
      final png = await pickedImageFromFile(XFile.fromData(bytes(10), name: 'foto.PNG'));
      expect(png!.name, 'foto.PNG');
      final heic = await pickedImageFromFile(XFile.fromData(bytes(10), name: 'foto.heic'));
      expect(heic!.name, 'foto.heic.jpg');
    });

    test('rechaza imágenes vacías o de más de 5 MB con un aviso', () async {
      final warnings = <String>[];
      expect(await pickedImageFromFile(XFile.fromData(bytes(0), name: 'a.jpg'), onWarning: warnings.add), isNull);
      expect(
        await pickedImageFromFile(XFile.fromData(bytes(2000), name: 'b.jpg'), maxBytes: 1000, onWarning: warnings.add),
        isNull,
      );
      expect(warnings.length, 2);
      expect(warnings.last, contains('5 MB'));
    });

    test('mensajes claros para permisos y cámara', () {
      String msg(String code, ImageSource s) => imagePickErrorMessage(PlatformException(code: code), s);
      expect(msg('camera_access_denied', ImageSource.camera), contains('cámara'));
      expect(msg('photo_access_denied', ImageSource.gallery), contains('fotos'));
      expect(msg('no_available_camera', ImageSource.camera), contains('cámara'));
      expect(msg('otro', ImageSource.camera), contains('cámara'));
      expect(msg('otro', ImageSource.gallery), contains('galería'));
    });
  });
}
