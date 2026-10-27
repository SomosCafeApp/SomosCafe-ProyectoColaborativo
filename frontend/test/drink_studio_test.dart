import 'dart:ui' show Offset;

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

Map<String, dynamic> _optionsJson({Map<String, num> syrups = const {}}) => {
      'sizes': {'Pequeño': 3000, 'Mediano': 0, 'Grande': 5000},
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
}

