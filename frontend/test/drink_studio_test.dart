import 'dart:ui' show Canvas, Offset, PictureRecorder;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:somoscafeapp/core/utils/latte_pour_engine.dart';
import 'package:somoscafeapp/core/utils/drink_profile.dart';
import 'package:somoscafeapp/core/utils/studio_prefs.dart';
import 'package:somoscafeapp/providers/drink_studio_provider.dart';
import 'package:somoscafeapp/models/drink_studio_stage.dart';
import 'package:somoscafeapp/widgets/drink_studio/latte_pour_session.dart';
import 'package:somoscafeapp/core/utils/money_format.dart';
import 'package:somoscafeapp/models/drink_options.dart';
import 'package:somoscafeapp/models/drink_recipe.dart';
import 'package:somoscafeapp/models/product_customization.dart';
import 'package:somoscafeapp/models/product_model.dart';
import 'package:somoscafeapp/widgets/drink_studio/latte_art_shapes.dart';
import 'package:somoscafeapp/widgets/drink_studio/milk_badge.dart';
import 'package:somoscafeapp/models/cup_snapshot.dart';
import 'package:somoscafeapp/providers/cart_provider.dart';
import 'package:somoscafeapp/models/price_quote.dart';
import 'package:somoscafeapp/widgets/drink_studio/sweetener_packet.dart';
import 'package:somoscafeapp/widgets/drink_studio/topping_painters.dart';

Map<String, dynamic> _optionsJson({Map<String, num> syrups = const {}}) => {
      'sizes': {'Pequeño': -3000, 'Mediano': 0, 'Grande': 5000},
      'types': ['Caliente', 'Frío'],
      'milks': {'Entera': 0, 'Avena': 1000},
      'extraShot': {'price': 3000, 'max': 6},
      'toppings': {'Canela': 1000},
      'syrups': {'prices': syrups, 'max': 3},
      'sweeteners': {'prices': {}, 'max': 2},
      'latteArt': {'keywords': ['latte'], 'designs': ['Corazón', 'Hoja', 'Cisne', 'Tulipán', 'Rosetta', 'Estrella']},
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
    expect(o.latteArtDesigns, ['Corazón', 'Hoja', 'Cisne', 'Tulipán', 'Rosetta', 'Estrella']);
    final c = ProductCustomization(size: 'Grande', milk: 'Avena', extraShots: 1, syrups: {'Vainilla'});
    expect(o.extraPriceOf(c), 5000 + 1000 + 3000 + 1500);
  });

  test('tamaños: pequeño resta, mediano base, grande suma', () {
    final o = DrinkOptions.fromJson(_optionsJson());
    double unit(String size) => 10000 + o.extraPriceOf(ProductCustomization(size: size));
    expect(unit('Pequeño'), 7000);
    expect(unit('Mediano'), 10000);
    expect(unit('Grande'), 15000);
    expect(unit('Pequeño') < unit('Mediano'), isTrue);
    // Mismo cálculo local (sin red) que el del servidor.
    expect(ProductCustomization(size: 'Pequeño').extraPrice, -3000);
    expect(formatExtra(-3000), r'-$3.000');
  });

  test('toppings con cantidad: primera al precio del catálogo, extras +\$300', () {
    final c = ProductCustomization(
      toppings: {'Canela', 'Chispas'},
      toppingQuantities: {'Canela': 3, 'Chispas': 1},
    );
    expect(c.quantityOf('Canela'), 3);
    expect(c.extraPrice, (1000 + 2 * 300) + 2500);
    expect(c.key, 'Mediano|Caliente|Entera|0|Canelax3,Chispas');
    final back = ProductCustomization.fromJson(c.toJson());
    expect(back.quantityOf('Canela'), 3);
    expect(back.extraPrice, c.extraPrice);
    // Formato del servidor: lista + toppingQuantities.
    final server = ProductCustomization.fromJson({
      'toppings': ['Canela'],
      'toppingQuantities': {'Canela': 2},
    });
    expect(server.extraPrice, 1000 + 300);
    // Lista antigua sin cantidades = 1 porción.
    expect(ProductCustomization.fromJson({'toppings': ['Canela']}).quantityOf('Canela'), 1);
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

  test('los seis diseños de latte art existen y tienen punto de vertido', () {
    expect(LatteArtShapes.designs, ['Corazón', 'Hoja', 'Cisne', 'Tulipán', 'Rosetta', 'Estrella']);
    for (final d in LatteArtShapes.designs) {
      final start = LatteArtShapes.pourPoint(d, 0);
      final end = LatteArtShapes.pourPoint(d, 1);
      expect(start.dx.isFinite && start.dy.isFinite, isTrue);
      expect(end.dx.isFinite && end.dy.isFinite, isTrue);
    }
  });

  group('arte latte interactivo', () {
    setUp(() => StudioPrefs.instance.haptics = false);

    DrinkStudioProvider studio() {
      final product = Product(id: '1', name: 'Latte', description: '', price: 8000, categoryName: 'Cafés calientes');
      final p = DrinkStudioProvider(product: product, catalog: <Product>[]);
      final o = DrinkOptions.fromJson(_optionsJson());
      p.options = o;
      p.profile = DrinkProfile.of(product, o);
      return p;
    }

    /// Barre la silueta como lo haría un dedo: mantiene presionado y arrastra por filas.
    void fill(LattePourSession s) {
      s.pointerDown(Offset.zero);
      for (var i = 0; i < 12; i++) {
        s.tick(0.016);
      }
      var guard = 0;
      for (var y = -0.65; y <= 0.85 && !s.completed; y += 0.12) {
        for (var x = -0.95; x <= 0.95 && !s.completed; x += 0.05) {
          s.pointerMove(Offset(x, y));
          s.tick(0.016);
          guard++;
        }
      }
      expect(guard, greaterThan(0));
    }

    test('las tres figuras tienen silueta rellenable', () {
      for (final d in LatteArtShapes.designs) {
        final sil = LatteArtShapes.silhouette(d);
        expect(sil, isNotNull, reason: d);
        expect(sil!.getBounds().isEmpty, isFalse, reason: d);
      }
      expect(LatteArtShapes.silhouette('Mariposa'), isNull);
      expect(LatteArtShapes.silhouette('Corazón')!.contains(const Offset(0, 0)), isTrue);
    });

    test('elegir una figura solo muestra la silueta: no rellena ni aplica arte', () {
      final s = studio();
      s.selectArt('Corazón');
      expect(s.pour.hasDesign, isTrue);
      expect(s.pour.progress, 0);
      expect(s.pour.completed, isFalse);
      expect(s.latteArt, '');
      expect(s.customization.latteArt, '');
      expect(s.artPending, isTrue);
      // El tiempo solo no completa nada.
      for (var i = 0; i < 500; i++) {
        s.pour.tick(0.016);
      }
      expect(s.pour.progress, 0);
    });

    test('verter con el dedo avanza el progreso y al completar el arte pasa a la bebida', () {
      final s = studio();
      s.selectArt('Corazón');
      fill(s.pour);
      expect(s.pour.completed, isTrue);
      expect(s.pour.doneTick, 1);
      expect(s.latteArt, 'Corazón');
      expect(s.customization.latteArt, 'Corazón');
      expect(s.snapshot.latteArt, 'Corazón');
      expect(s.artPending, isFalse);
      expect(s.pour.accuracy, greaterThan(0.3));
    });

    test('mantener presionado en un punto hace avanzar el relleno sin completarlo', () {
      final s = studio();
      s.selectArt('Corazón');
      s.pour.pointerDown(Offset.zero);
      for (var i = 0; i < 12; i++) {
        s.pour.tick(0.016);
      }
      final a = s.pour.progress;
      for (var i = 0; i < 60; i++) {
        s.pour.tick(0.016);
      }
      expect(s.pour.progress, greaterThan(a));
      expect(s.pour.completed, isFalse);
    });

    test('reiniciar el vertido conserva el diseño y la etapa', () {
      final s = studio();
      s.selectArt('Hoja');
      fill(s.pour);
      s.pour.pointerUp();
      s.restartPour();
      expect(s.pour.design, 'Hoja');
      expect(s.pour.progress, 0);
      expect(s.pour.stamps, isEmpty);
      expect(s.pour.completed, isFalse);
      expect(s.latteArt, '');
    });

    test('el progreso se conserva al navegar entre etapas', () {
      final s = studio();
      s.selectArt('Corazón');
      s.pour.pointerDown(Offset.zero);
      for (var i = 0; i < 40; i++) {
        s.pour.tick(0.016);
      }
      s.pour.pointerUp();
      final p = s.pour.progress;
      expect(p, greaterThan(0));
      s.step = StudioStep.art;
      s.back();
      s.next();
      expect(s.pour.progress, p);
      expect(s.pour.design, 'Corazón');
    });

    test('cambiar a bebida fría oculta el arte pero no lo pierde', () {
      final s = studio();
      s.selectArt('Corazón');
      fill(s.pour);
      expect(s.latteArt, 'Corazón');
      s.setType('Frío');
      expect(s.latteArt, '');
      s.setType('Caliente');
      expect(s.latteArt, 'Corazón');
    });

    test('reiniciar la etapa actual solo toca esa etapa', () {
      final s = studio();
      s.setSize('Grande');
      s.changeShots(1);
      s.toggleTopping('Canela');
      s.step = StudioStep.toppings;
      s.resetCurrentStep();
      expect(s.toppings, isEmpty);
      expect(s.size, 'Grande');
      expect(s.shots, 1);
      s.step = StudioStep.base;
      s.resetCurrentStep();
      expect(s.shots, 0);
      expect(s.size, 'Grande');
      s.step = StudioStep.result;
      expect(s.canResetStep, isFalse);
    });

    test('una receta guardada carga el arte ya terminado y se puede reiniciar', () {
      final s = studio();
      s.pour.loadCompleted('Cisne');
      expect(s.latteArt, 'Cisne');
      expect(s.pour.doneTick, 0);
      s.restartPour();
      expect(s.latteArt, '');
      expect(s.pour.design, 'Cisne');
    });

    test('sin diseño elegido no cae leche', () {
      final s = LattePourSession();
      s.pointerDown(Offset.zero);
      s.tick(0.016);
      expect(s.pouring, isFalse);
      expect(s.stamps, isEmpty);
    });
  });

  group('modo desafío, puntuación y preferencias', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      StudioPrefs.instance.haptics = false;
    });

    DrinkStudioProvider studio() {
      final product = Product(id: '1', name: 'Latte', description: '', price: 8000, categoryName: 'Cafés calientes');
      final p = DrinkStudioProvider(product: product, catalog: <Product>[]);
      final o = DrinkOptions.fromJson(_optionsJson());
      p.options = o;
      p.profile = DrinkProfile.of(product, o);
      return p;
    }

    test('el modo libre nunca puntúa', () {
      final s = studio();
      expect(s.mode, StudioMode.free);
      expect(s.pour.scoring, isFalse);
      s.selectArt('Corazón');
      expect(s.pour.score, isNull);
    });

    test('el desafío sortea un diseño real y activa la puntuación', () {
      final s = studio();
      s.setMode(StudioMode.challenge);
      expect(s.pour.scoring, isTrue);
      expect(s.challengeDesign, isNotEmpty);
      expect(LatteArtShapes.designs, contains(s.challengeDesign));
      expect(s.pour.design, s.challengeDesign);
      for (var i = 0; i < 12; i++) {
        final before = s.challengeDesign;
        s.newChallenge();
        expect(s.challengeDesign, isNot(before));
      }
      s.setMode(StudioMode.free);
      expect(s.pour.scoring, isFalse);
    });

    test('las seis figuras tienen silueta y se pueden elegir', () {
      final s = studio();
      for (final d in LatteArtShapes.designs) {
        s.selectArt(d);
        expect(s.pour.silhouette, isNotNull, reason: d);
        expect(s.pour.guide, isNotNull, reason: d);
        expect(s.pour.progress, 0, reason: d);
      }
    });

    test('terminar un reto da puntos y registra el récord', () {
      final s = studio();
      s.setMode(StudioMode.challenge);
      s.selectArt('Corazón');
      final sess = s.pour;
      sess.pointerDown(Offset.zero);
      for (var i = 0; i < 12; i++) {
        sess.tick(0.016);
      }
      for (var y = -0.65; y <= 0.85 && !sess.completed; y += 0.12) {
        for (var x = -0.95; x <= 0.95 && !sess.completed; x += 0.05) {
          sess.pointerMove(Offset(x, y));
          sess.tick(0.016);
        }
      }
      expect(sess.completed, isTrue);
      expect(sess.score, isNotNull);
      expect(sess.score!.points, inInclusiveRange(40, 100));
      expect(sess.newRecord, isTrue);
      expect(StudioPrefs.instance.bestScores['Corazón'], sess.score!.points);
      expect(StudioPrefs.instance.recordBest('Corazón', 1), isFalse);
    });

    test('puntuación: terminar vale 40 y la precisión suma hasta 100', () {
      expect(ArtScore.of(0).points, 40);
      expect(ArtScore.of(1).points, 100);
      expect(ArtScore.of(1).stars, 3);
    });

    test('el nombre del vaso: por defecto el de la bebida, máximo 18 letras', () {
      final s = studio();
      expect(s.cupLabel, 'Latte');
      expect(s.snapshot.label, 'Latte');
      s.setCupName('  Mi café  ');
      expect(s.cupLabel, 'Mi café');
      s.setCupName('a' * 40);
      expect(s.cupName.length, 18);
      s.setCupName('');
      expect(s.cupLabel, 'Latte');
    });

    test('los tamaños crecen de forma proporcional a las onzas', () {
      final s = studio();
      s.setSize('Pequeño');
      final small = s.sizeFactor;
      s.setSize('Mediano');
      final medium = s.sizeFactor;
      s.setSize('Grande');
      final large = s.sizeFactor;
      expect(small, lessThan(medium));
      expect(medium, closeTo(1, 1e-9));
      expect(large, greaterThan(medium));
    });

    test('las preferencias avisan y apagan vibración, efectos y animaciones', () {
      final prefs = StudioPrefs.instance;
      var calls = 0;
      void l() => calls++;
      prefs.addListener(l);
      prefs.setEffects(false);
      prefs.setAnimations(false);
      prefs.setHaptics(false);
      prefs.setEffects(false); // sin cambio: no avisa
      expect(calls, 3);
      expect([prefs.effects, prefs.animations, prefs.haptics], [false, false, false]);
      prefs.setEffects(true);
      prefs.setAnimations(true);
      prefs.removeListener(l);
    });

    test('reiniciar todo devuelve el modo libre y borra el nombre', () {
      final s = studio();
      s.setMode(StudioMode.challenge);
      s.setCupName('X');
      s.restart();
      expect(s.mode, StudioMode.free);
      expect(s.pour.scoring, isFalse);
      expect(s.cupName, '');
      expect(s.pour.hasDesign, isFalse);
    });
  });

  group('micro-animaciones por etapa', () {
    test('avanzar completa la etapa (sube el contador) y retroceder no', () {
      final product = Product(id: '1', name: 'Latte', description: '', price: 8000, categoryName: 'Cafés calientes');
      final p = DrinkStudioProvider(product: product, catalog: <Product>[]);
      final o = DrinkOptions.fromJson(_optionsJson());
      p.options = o;
      p.profile = DrinkProfile.of(product, o);
      expect(p.stepDoneTick, 0);
      p.next();
      expect(p.stepDoneTick, 1);
      p.next();
      expect(p.stepDoneTick, 2);
      p.back();
      expect(p.stepDoneTick, 2);
      // En la última etapa no hay a dónde avanzar: no cuenta.
      while (p.step != p.steps.last) {
        p.next();
      }
      final before = p.stepDoneTick;
      p.next();
      expect(p.stepDoneTick, before);
    });
  });

  group('toppings nuevos, endulzantes y desglose de precio', () {
    setUp(() => StudioPrefs.instance.haptics = false);

    Map<String, dynamic> json() => {
          ..._optionsJson(),
          'toppings': {'Canela': 1000, 'Cacao en polvo': 1000, 'Malvaviscos': 1800},
          'toppingRules': {
            'extraPortionPrice': 300,
            'maxQuantity': 5,
            'compatibility': {
              'Cacao en polvo': {'keywords': ['latte', 'moca']},
              'Malvaviscos': {'types': ['Caliente'], 'keywords': ['moca', 'chocolate', 'latte']},
            },
          },
          'sweeteners': {'prices': {'Azúcar blanca': 0, 'Azúcar morena': 0, 'Estevia': 0}, 'max': 3},
        };

    DrinkStudioProvider studio({String name = 'Moca'}) {
      final product = Product(id: '1', name: name, description: '', price: 8000, categoryName: 'Cafés calientes');
      final p = DrinkStudioProvider(product: product, catalog: <Product>[]);
      final o = DrinkOptions.fromJson(json());
      p.options = o;
      p.profile = DrinkProfile.of(product, o);
      return p;
    }

    test('solo se ofrecen los toppings compatibles con la bebida y la temperatura', () {
      final s = studio();
      expect(s.availableToppings.keys, containsAll(['Canela', 'Cacao en polvo', 'Malvaviscos']));
      s.setType('Frío');
      expect(s.availableToppings.keys, isNot(contains('Malvaviscos')));
      expect(s.availableToppings.keys, contains('Cacao en polvo'));
      final tea = studio(name: 'Té chai');
      expect(tea.availableToppings.keys, ['Canela']);
    });

    test('al pasar a frío se retiran los malvaviscos ya elegidos', () {
      final s = studio();
      expect(s.toggleTopping('Malvaviscos'), isTrue);
      s.changeToppingQuantity('Malvaviscos', 1);
      s.setType('Frío');
      expect(s.toppings, isNot(contains('Malvaviscos')));
      expect(s.toggleTopping('Malvaviscos'), isFalse);
    });

    test('cada porción extra suma \$300 y el desglose coincide con el total', () {
      final s = studio();
      s.toggleTopping('Canela');
      s.changeToppingQuantity('Canela', 2); // 3 porciones: 1000 + 2 × 300
      s.toggleTopping('Cacao en polvo');
      s.setSize('Grande');
      s.toggleSweetener('Estevia');
      expect(s.toppingQuantity('Canela'), 3);
      final lines = s.priceLines;
      final canela = lines.firstWhere((l) => l.label.startsWith('Canela'));
      expect(canela.amount, 1000 + 2 * 300);
      expect(canela.label, 'Canela × 3');
      expect(canela.detail, '2 extra × \$300');
      expect(s.sizeAdjustment, 5000);
      expect(s.sizeAdjustment + lines.fold<double>(0, (a, l) => a + l.amount), s.extraPerUnit);
      expect(s.quote.unitPrice, s.unitPrice);
      expect(s.unitPrice, 8000 + s.extraPerUnit);
    });

    test('máximo de endulzantes y snapshot con sobres y porciones', () {
      final s = studio();
      expect(s.toggleSweetener('Azúcar blanca'), isTrue);
      expect(s.toggleSweetener('Azúcar morena'), isTrue);
      expect(s.toggleSweetener('Estevia'), isTrue);
      s.toggleTopping('Canela');
      s.changeToppingQuantity('Canela', 1);
      final snap = s.snapshot;
      expect(snap.sweeteners, ['Azúcar blanca', 'Azúcar morena', 'Estevia']);
      expect(snap.qtyOf('Canela'), 2);
      expect(snap.qtyOf('Malvaviscos'), 0);
    });

    test('los pintores de toppings y sobres dibujan todas las combinaciones sin fallar', () {
      const names = ['Crema batida', 'Canela', 'Chispas', 'Caramelo', 'Cacao en polvo', 'Virutas de chocolate', 'Malvaviscos'];
      for (final art in [false, true]) {
        for (final top in [false, true]) {
          for (final q in [1, 3, 5]) {
            final canvas = Canvas(PictureRecorder());
            ToppingPainters.paint(canvas, const Offset(150, 150), 100, top ? 100 : 40, names, {for (final n in names) n: q}, hasArt: art, topView: top);
          }
        }
      }
      for (final n in ['Azúcar blanca', 'Azúcar morena', 'Estevia', 'Panela', 'Miel', 'Otro']) {
        SweetenerPacketPainter.paint(Canvas(PictureRecorder()), const Offset(40, 50), 36, n, angle: 0.2);
      }
      expect(ToppingPainters.kindOf('Virutas de chocolate'), ToppingKind.shavings);
      expect(ToppingPainters.kindOf('Cacao en polvo'), ToppingKind.cocoa);
      expect(ToppingPainters.kindOf('Malvaviscos'), ToppingKind.marshmallow);
    });

    test('el trazo del arte latte nunca es más fino que el base', () {
      final fast = LattePourEngine(mask: List<bool>.filled(32 * 32, true));
      final slow = LattePourEngine(mask: List<bool>.filled(32 * 32, true));
      fast.pour(0, 0, 0.016);
      slow.pour(0, 0, 0.016);
      fast.pour(0.6, 0, 0.016); // rápido: ~37 u/s
      slow.pour(0.6, 0, 1.5); // lento: 0,4 u/s
      expect(fast.stamps.last.r, closeTo(fast.brush, 1e-9));
      expect(slow.stamps.last.r, greaterThan(slow.brush));
      expect(slow.stamps.last.r, lessThanOrEqualTo(slow.brush * 1.3));
    });
  });

  group('precios unificados (mismas reglas que el backend)', () {
    double unit(double base, String size, {double? effective}) => ProductCustomization(size: size).quote(basePrice: base, effectivePrice: effective).unitPrice;

    test('Pequeño base-3.000 · Mediano base · Grande base+5.000', () {
      expect(unit(12000, 'Pequeño'), 9000);
      expect(unit(12000, 'Mediano'), 12000);
      expect(unit(12000, 'Grande'), 17000);
    });

    test('Pequeño ≤ Mediano ≤ Grande y nunca negativo en cualquier precio base', () {
      for (var base = 0.0; base <= 40000; base += 250) {
        final s = unit(base, 'Pequeño'), m = unit(base, 'Mediano'), g = unit(base, 'Grande');
        expect(s <= m && m <= g, isTrue, reason: 'base $base');
        expect(s >= 0, isTrue, reason: 'base $base');
        expect(m, base);
      }
    });

    test('productos baratos: el descuento del Pequeño se recorta al piso', () {
      expect(ProductCustomization.sizeAdjustment('Pequeño', 3500), -2500);
      expect(ProductCustomization.sizeAdjustment('Pequeño', 1000), 0);
      expect(ProductCustomization.sizeAdjustment('Pequeño', 500), 0);
      expect(ProductCustomization.sizeAdjustment('Pequeño', 8000), -3000);
      expect(ProductCustomization.sizeAdjustment('Grande', 500), 5000);
    });

    test('adicionales: leche, shots y +\$300 por porción extra de topping', () {
      final c = ProductCustomization(
        size: 'Grande',
        milk: 'Deslactosada',
        extraShots: 2,
        toppings: {'Canela', 'Cacao en polvo'},
        toppingQuantities: {'Canela': 3},
      );
      final q = c.quote(basePrice: 10000);
      expect(q.sizeAdjustment, 5000);
      expect(q.lines.firstWhere((l) => l.label == 'Leche Deslactosada').amount, 1000);
      expect(q.lines.firstWhere((l) => l.label.startsWith('Shots')).amount, 6000);
      final canela = q.lines.firstWhere((l) => l.label == 'Canela × 3');
      expect(canela.amount, 1000 + 2 * 300);
      expect(canela.detail, '2 extra × \$300');
      expect(q.originalUnitPrice, 10000 + 5000 + 1000 + 6000 + 1600 + 1000);
      expect(c.extraPriceFor(10000), q.customizationPrice);
    });

    test('el descuento se aplica al precio base y nunca deja la unidad en negativo', () {
      final c = ProductCustomization(size: 'Grande', extraShots: 1);
      final q = c.quote(basePrice: 10000, effectivePrice: 8000, promotionName: 'Promo');
      expect(q.discountPerUnit, 2000);
      expect(q.originalUnitPrice, 18000);
      expect(q.unitPrice, 16000);
      expect(q.total(2), 32000);
      expect(q.subtotal(2), 36000);
      final free = ProductCustomization(size: 'Pequeño').quote(basePrice: 4000, effectivePrice: 0);
      expect(free.originalUnitPrice, 1000);
      expect(free.discountPerUnit, 1000);
      expect(free.unitPrice, 0);
    });

    test('las tablas del servidor reemplazan a las de respaldo', () {
      final saved = (ProductCustomization.sizePrices, ProductCustomization.milkPrices, ProductCustomization.extraShotPrice);
      addTearDown(() {
        ProductCustomization.sizePrices = saved.$1;
        ProductCustomization.milkPrices = saved.$2;
        ProductCustomization.extraShotPrice = saved.$3;
      });
      final o = DrinkOptions.fromJson({
        ..._optionsJson(),
        'sizes': {'Pequeño': -2000, 'Mediano': 0, 'Grande': 4000},
        'milks': {'Entera': 0, 'Coco': 1500},
        'extraShot': {'price': 3500, 'max': 6},
      });
      o.register();
      expect(ProductCustomization.sizeAdjustment('Pequeño', 10000), -2000);
      expect(ProductCustomization.milkPrices['Coco'], 1500);
      expect(ProductCustomization(extraShots: 2, size: 'Grande').quote(basePrice: 10000).customizationPrice, 4000 + 7000);
    });

    test('la línea del carrito local usa el mismo cálculo y su desglose cuadra', () {
      final product = Product(id: '1', name: 'Latte', description: '', price: 7000, categoryName: 'Cafés calientes');
      final c = ProductCustomization(size: 'Pequeño', milk: 'Soya', extraShots: 1, toppings: {'Canela'}, toppingQuantities: {'Canela': 2});
      final q = c.quote(basePrice: 7000);
      final line = CartLine(
        id: 'l1',
        product: product,
        quantity: 3,
        customization: c,
        originalUnitPrice: q.originalUnitPrice,
        sizeAdjustment: q.sizeAdjustment,
        extraLines: q.lines,
      );
      expect(line.originalUnitPrice, 7000 - 3000 + 2000 + 3000 + 1300);
      expect(line.hasConsistentBreakdown, isTrue);
      expect(line.lineTotal, line.originalUnitPrice * 3);
      expect(line.quote.total(3), line.lineTotal);
      // Un desglose que no cuadra con el precio del servidor se oculta.
      final off = CartLine(id: 'l2', product: product, quantity: 1, customization: c, originalUnitPrice: 99999);
      expect(off.hasConsistentBreakdown, isFalse);
    });
  });
}
