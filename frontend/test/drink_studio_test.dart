import 'package:flutter_test/flutter_test.dart';
import 'package:somoscafeapp/core/utils/money_format.dart';
import 'package:somoscafeapp/models/drink_options.dart';
import 'package:somoscafeapp/models/drink_recipe.dart';
import 'package:somoscafeapp/models/product_customization.dart';
import 'package:somoscafeapp/models/product_model.dart';
import 'package:somoscafeapp/widgets/drink_studio/latte_art_shapes.dart';
import 'package:somoscafeapp/widgets/drink_studio/milk_badge.dart';

Map<String, dynamic> _optionsJson({Map<String, num> syrups = const {}}) => {
      'sizes': {'Pequeño': 3000, 'Mediano': 0, 'Grande': 5000},
      'types': ['Caliente', 'Frío'],
      'milks': {'Entera': 0, 'Avena': 1000},
      'extraShot': {'price': 3000, 'max': 6},
      'toppings': {'Canela': 1000},
      'syrups': {'prices': syrups, 'max': 3},
      'sweeteners': {'prices': {}, 'max': 2},
      'latteArt': {'keywords': ['latte'], 'designs': ['Corazón', 'Hoja', 'Cisne']},
      'sizeOunces': {'Pequeño': 8, 'Mediano': 12, 'Grande': 16},
      'coffeeKeywords': ['café', 'latte'],
      'defaults': {'size': 'Mediano', 'type': 'Caliente', 'milk': 'Entera'},
    };

void main() {
  test('la clave de personalización coincide con la del backend', () {
    expect(ProductCustomization().key, 'Mediano|Caliente|Entera|0|');
    expect(
      ProductCustomization(size: 'Grande', type: 'Frío', milk: 'Soya', extraShots: 1, toppings: {'Canela'}).key,
      'Grande|Frío|Soya|1|Canela',
    );
  });

  test('latte art cambia la clave y se resume por nombre', () {
    final a = ProductCustomization(latteArt: 'Cisne');
    expect(a.key, 'Mediano|Caliente|Entera|0||a:Cisne');
    expect(a.key, isNot(ProductCustomization(latteArt: 'Hoja').key));
    expect(a.summaryLines.join(' '), contains('Latte art: Cisne'));
    expect(a.isDefault, isFalse);
  });

  test('toJson/fromJson conserva jarabes, endulzantes y latte art', () {
    final c = ProductCustomization(syrups: {'X'}, sweeteners: {'Y'}, latteArt: 'Hoja');
    final back = ProductCustomization.fromJson(c.toJson());
    expect(back.syrups, {'X'});
    expect(back.sweeteners, {'Y'});
    expect(back.latteArt, 'Hoja');
    expect(back.hasLatteArt, isTrue);
  });

  test('DrinkRecipe lee la respuesta del backend', () {
    final r = DrinkRecipe.fromJson({
      'id': 'r1',
      'name': '',
      'isSaved': true,
      'productId': 'p1',
      'available': true,
      'extraPrice': 2000,
      'product': {'name': 'Latte', 'price': 8000, 'image': null},
      'customization': {'size': 'Grande', 'latteArt': 'Corazón', 'milkLevel': 0.8},
    });
    expect(r.title, 'Latte');
    expect(r.totalPrice, 10000);
    expect(r.customization.size, 'Grande');
    expect(r.customization.latteArt, 'Corazón');
    expect(r.milkLevel, 0.8);
  });

  test('DrinkOptions calcula el extra con precios reales', () {
    final o = DrinkOptions.fromJson(_optionsJson(syrups: {'Vainilla': 1500}));
    expect(o.hasSyrups, isTrue);
    expect(o.hasSweeteners, isFalse);
    expect(o.ouncesOf('Grande'), 16);
    expect(o.latteArtDesigns, ['Corazón', 'Hoja', 'Cisne']);
    final c = ProductCustomization(size: 'Grande', milk: 'Avena', extraShots: 1, syrups: {'Vainilla'});
    expect(o.extraPriceOf(c), 5000 + 1000 + 3000 + 1500);
  });

  test('sin catálogo de jarabes la etapa no existe', () {
    expect(DrinkOptions.fromJson(_optionsJson()).hasSyrups, isFalse);
  });

  test('isDrink solo para bebidas, nunca postres ni sin categoría', () {
    Product p(String? cat) => Product(id: '1', name: 'x', description: '', price: 1, categoryName: cat);
    expect(p('Cafés calientes').isDrink, isTrue);
    expect(p('Postres').isDrink, isFalse);
    expect(p(null).isDrink, isFalse);
  });

  test('formatCop', () {
    expect(formatCop(12500), r'$12.500');
    expect(formatExtra(0), 'Incluido');
  });

  test('cada leche tiene su ilustración, incluida la deslactosada', () {
    expect(milkKindOf('Entera'), MilkKind.cow);
    expect(milkKindOf('Deslactosada'), MilkKind.lactoseFree);
    expect(milkKindOf('Soya'), MilkKind.soy);
    expect(milkKindOf('Almendra'), MilkKind.almond);
    expect(milkKindOf('Avena'), MilkKind.oat);
    expect(milkKindOf('Otra'), MilkKind.generic);
  });

  test('los tres diseños de latte art existen y tienen punto de vertido', () {
    expect(LatteArtShapes.designs, ['Corazón', 'Hoja', 'Cisne']);
    for (final d in LatteArtShapes.designs) {
      final start = LatteArtShapes.pourPoint(d, 0);
      final end = LatteArtShapes.pourPoint(d, 1);
      expect(start.dx.isFinite && start.dy.isFinite, isTrue);
      expect(end.dx.isFinite && end.dy.isFinite, isTrue);
    }
  });
}
