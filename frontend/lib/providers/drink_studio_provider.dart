import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/utils/drink_profile.dart';
import '../core/utils/studio_prefs.dart';
import '../models/cup_snapshot.dart';
import '../models/drink_options.dart';
import '../models/drink_recipe.dart';
import '../models/drink_studio_stage.dart';
import '../models/product_customization.dart';
import '../models/product_model.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';
import '../widgets/drink_studio/latte_art_shapes.dart';
import '../widgets/drink_studio/latte_pour_session.dart';
import 'cart_provider.dart';
import 'recipes_provider.dart';

enum StudioLoad { loading, error, ready }

/// Resultado de agregar la creación al carrito.
class StudioAddResult {
  final bool drinkAdded;
  final String? error;
  const StudioAddResult({required this.drinkAdded, this.error});
}

/// Estado del estudio de bebidas: UNA sola pantalla donde cada acción
/// actualiza el vaso al instante. Las opciones y precios vienen del
/// backend; los acompañamientos son los postres reales del menú.
class DrinkStudioProvider extends ChangeNotifier {
  DrinkStudioProvider({required this.product, required List<Product> catalog}) : _catalog = catalog {
    // Cambiar vibración / efectos / animaciones repinta el estudio al instante.
    StudioPrefs.instance.addListener(_onPrefs);
    StudioPrefs.instance.load();
  }

  void _onPrefs() => notifyListeners();

  /// En el desafío, un diseño terminado puede ser récord.
  void _onArtDone(LattePourSession s) {
    final score = s.score;
    if (mode == StudioMode.challenge && score != null) {
      s.newRecord = StudioPrefs.instance.recordBest(s.design, score.points);
    }
  }

  final Product product;
  final List<Product> _catalog;

  StudioLoad status = StudioLoad.loading;
  String? error;
  DrinkOptions? options;
  DrinkProfile? profile;

  // Elecciones
  String size = ProductCustomization.defaultSize;
  String type = ProductCustomization.defaultType;
  String milk = ProductCustomization.defaultMilk;
  int shots = 0;
  int quantity = 1;
  double milkLevel = 0.55;
  final Set<String> toppings = {};
  final Set<String> syrups = {};
  final Set<String> sweeteners = {};
  final Map<String, Product> pairings = {};

  // Interfaz
  StudioStep step = StudioStep.size;

  /// Sección más avanzada a la que ya llegó (permite volver a las anteriores).
  int furthest = 0;
  bool adding = false;

  // Transición entre secciones
  StudioTransition transition = StudioTransition.none;
  int transitionTick = 0;

  /// +1 al avanzar (el vaso entra desde la izquierda), -1 al retroceder.
  int transitionDir = 1;

  /// Vertido interactivo del arte latte: diseño elegido (silueta),
  /// leche vertida y progreso. Se conserva al navegar entre etapas.
  late final LattePourSession pour = LattePourSession(onCoarseChange: () => notifyListeners(), onDone: _onArtDone);

  // Modo de juego del arte latte
  StudioMode mode = StudioMode.free;

  /// Diseño que hay que completar en el modo desafío.
  String challengeDesign = '';
  final math.Random _rng = math.Random();

  /// Nombre que se imprime en la etiqueta del vaso ('' = nombre de la bebida).
  String cupName = '';

  // Efectos
  PourKind pourKind = PourKind.none;
  int pourTick = 0;
  int milkPopTick = 0;
  String milkPopName = '';

  /// Última receta de esta bebida (para ofrecer "retomar").
  DrinkRecipe? lastRecipe;

  bool _disposed = false;

  @override
  void notifyListeners() {
    // Las cargas asíncronas pueden terminar cuando la pantalla ya se cerró.
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    StudioPrefs.instance.removeListener(_onPrefs);
    pour.dispose();
    super.dispose();
  }

  Future<void> load() async {
    status = StudioLoad.loading;
    error = null;
    notifyListeners();
    try {
      final data = await ApiClient.get('/customization/options');
      final loaded = DrinkOptions.fromJson(data['options'] as Map<String, dynamic>);
      if (!loaded.isUsable) {
        throw ApiException('El menú aún no tiene opciones de personalización (tamaños, tipos y leches).');
      }
      loaded.register();
      options = loaded;
      profile = DrinkProfile.of(product, loaded);
      _applyDefaults(loaded);
      status = StudioLoad.ready;
    } on ApiException catch (e) {
      error = e.message;
      status = StudioLoad.error;
    } catch (_) {
      error = 'No pudimos cargar las opciones de tu bebida.';
      status = StudioLoad.error;
    }
    notifyListeners();
  }

  static String _defaultSize(DrinkOptions o) => o.sizes.containsKey(o.defaultSize) ? o.defaultSize : o.sizes.keys.first;
  static String _defaultType(DrinkOptions o) => o.types.contains(o.defaultType) ? o.defaultType : o.types.first;
  static String _defaultMilk(DrinkOptions o) => o.milks.containsKey(o.defaultMilk) ? o.defaultMilk : o.milks.keys.first;

  void _applyDefaults(DrinkOptions o) {
    size = _defaultSize(o);
    type = _defaultType(o);
    milk = _defaultMilk(o);
  }

  // ───────────── Datos derivados ─────────────

  bool get isHot => type == ProductCustomization.defaultType;
  bool get canLatteArt => (profile?.supportsLatteArt ?? false) && isHot;

  /// Arte latte TERMINADO de la bebida (lo único que viaja al pedido).
  /// Elegir una figura solo muestra su silueta: el diseño cuenta cuando
  /// el usuario termina de rellenarla.
  String get latteArt => canLatteArt && pour.completed ? pour.design : '';

  /// Texto de la etiqueta del vaso.
  String get cupLabel => cupName.trim().isEmpty ? product.name : cupName.trim();

  void setCupName(String v) {
    cupName = v.length > 18 ? v.substring(0, 18) : v;
    notifyListeners();
  }

  /// Diseños que la app sabe dibujar y la bebida admite.
  List<String> get _playableDesigns => (options?.latteArtDesigns ?? const <String>[]).where((d) => LatteArtShapes.silhouette(d) != null).toList();

  /// Cambia entre arte libre (sin puntos) y desafío (con puntuación).
  void setMode(StudioMode m) {
    if (mode == m) return;
    mode = m;
    pour.scoring = m == StudioMode.challenge;
    if (m == StudioMode.challenge) {
      newChallenge();
    } else {
      notifyListeners();
    }
  }

  /// Sortea un diseño distinto al actual y deja listo el vertido.
  void newChallenge() {
    final pool = _playableDesigns;
    if (pool.isEmpty) return;
    final others = pool.where((d) => d != challengeDesign).toList();
    final list = others.isEmpty ? pool : others;
    challengeDesign = list[_rng.nextInt(list.length)];
    pour.selectDesign(challengeDesign);
    // selectDesign no avisa si el diseño era el mismo.
    notifyListeners();
  }

  /// Hay un diseño elegido a medio verter (para avisar antes de seguir).
  bool get artPending => canLatteArt && pour.pending;

  /// El vaso responde al dedo (vertido) solo en la etapa de arte.
  bool get artInteractive => step == StudioStep.art && canLatteArt;
  bool get isCoffee => profile?.isCoffee ?? false;

  /// Postres reales disponibles para acompañar.
  List<Product> get availablePairings =>
      _catalog.where((p) => p.isAvailable && !p.isCustomizable && p.id != product.id).toList();

  /// Secciones del flujo, en orden. El arte latte solo en bebidas
  /// calientes con espuma; los toppings solo si hay algo que elegir.
  List<StudioStep> get steps {
    final o = options;
    if (o == null) return const [];
    return [
      StudioStep.size,
      StudioStep.base,
      StudioStep.milk,
      if (canLatteArt && o.latteArtDesigns.isNotEmpty) StudioStep.art,
      if (o.toppings.isNotEmpty || o.hasSyrups || o.hasSweeteners) StudioStep.toppings,
      StudioStep.result,
    ];
  }

  int get stepIndex {
    final i = steps.indexOf(step);
    return i < 0 ? 0 : i;
  }

  bool get isFirstStep => stepIndex == 0;
  bool get showSummary => step == StudioStep.result;

  /// Avance del recorrido (0..1).
  double get progress => steps.length < 2 ? 0 : stepIndex / (steps.length - 1);

  /// Cómo se dibuja el vaso en la sección actual.
  CupView get view => switch (step) {
        StudioStep.art => CupView.tilt,
        StudioStep.toppings => CupView.top,
        _ => CupView.side,
      };

  int? get ounces => options?.ouncesOf(size);

  /// Escala del vaso: alto y ancho crecen juntos, así el volumen
  /// visual sigue a las onzas (referencia: 12 oz).
  double get sizeFactor {
    final oz = ounces;
    if (oz != null && oz > 0) return math.pow(oz / 12, 0.6).toDouble();
    final keys = options?.sizes.keys.toList() ?? const <String>[];
    final i = keys.indexOf(size);
    return keys.length < 2 || i < 0 ? 1.0 : 0.85 + 0.3 * i / (keys.length - 1);
  }

  /// Ya hay algo preparado (para confirmar antes de salir).
  bool get hasProgress => !customization.isDefault || pairings.isNotEmpty || stepIndex > 0;

  ProductCustomization get customization => ProductCustomization(
        size: size,
        type: type,
        milk: milk,
        extraShots: shots,
        toppings: Set<String>.from(toppings),
        syrups: Set<String>.from(syrups),
        sweeteners: Set<String>.from(sweeteners),
        latteArt: latteArt,
      );

  double get extraPerUnit => options?.extraPriceOf(customization) ?? 0;
  double get unitPrice => product.effectivePrice + extraPerUnit;
  double get drinkTotal => unitPrice * quantity;
  double get pairingsTotal => pairings.values.fold(0.0, (sum, p) => sum + p.effectivePrice);
  double get total => drinkTotal + pairingsTotal;

  CupSnapshot get snapshot => CupSnapshot(
        sizeFactor: sizeFactor,
        ounces: ounces,
        isHot: isHot,
        isCoffee: isCoffee,
        baseColor: profile?.baseColor ?? const Color(0xFF4A2C1B),
        shots: shots,
        milkLevel: milkLevel,
        milkColor: DrinkProfile.milkColorFor(milk),
        toppings: toppings.toList()..sort(),
        syrups: syrups.toList()..sort(),
        sweeteners: sweeteners.length,
        latteArt: latteArt,
        label: cupLabel,
      );

  // ───────────── Elecciones ─────────────

  void _pour(PourKind kind) {
    pourKind = kind;
    pourTick++;
  }

  void setSize(String v) {
    size = v;
    notifyListeners();
  }

  void setType(String v) {
    type = v;
    notifyListeners();
  }

  void setMilk(String v) {
    milk = v;
    milkPopName = v;
    milkPopTick++;
    _pour(PourKind.milk);
    notifyListeners();
  }

  void changeShots(int delta) {
    final max = options?.maxExtraShots ?? 0;
    final next = (shots + delta).clamp(0, max).toInt();
    if (next == shots) return;
    shots = next;
    if (delta > 0) _pour(PourKind.espresso);
    notifyListeners();
  }

  /// Sube o baja la cantidad de leche (0 = sin leche, 0.92 = hasta el borde).
  void changeMilk(double delta) {
    final next = (milkLevel + delta).clamp(0.0, 0.92).toDouble();
    if (next == milkLevel) return;
    milkLevel = next;
    if (delta > 0) _pour(PourKind.milk);
    notifyListeners();
  }

  void changeQuantity(int delta) {
    quantity = (quantity + delta).clamp(1, 20).toInt();
    notifyListeners();
  }

  /// Alterna [name] en [set] respetando [max]. Devuelve false si no cabe.
  bool _toggle(Set<String> set, String name, int max, PourKind kind) {
    if (!set.remove(name)) {
      if (set.length >= max) return false;
      set.add(name);
      _pour(kind);
    }
    notifyListeners();
    return true;
  }

  bool toggleTopping(String n) => _toggle(toppings, n, 99, PourKind.topping);
  bool toggleSyrup(String n) => _toggle(syrups, n, options?.maxSyrups ?? 0, PourKind.syrup);
  bool toggleSweetener(String n) => _toggle(sweeteners, n, options?.maxSweeteners ?? 0, PourKind.sweetener);

  /// Elige el diseño ('' = sin arte). Muestra la silueta guía: NO
  /// rellena nada, eso lo hace el usuario vertiendo.
  void selectArt(String design) => pour.selectDesign(design);

  /// Borra la leche vertida y deja la silueta lista para empezar de
  /// nuevo, sin salir de la etapa ni perder las demás elecciones.
  void restartPour() => pour.restart();

  // ───────────── Acompañamientos ─────────────

  void togglePairing(Product p) {
    if (pairings.remove(p.id) == null) pairings[p.id] = p;
    notifyListeners();
  }

  // ───────────── Navegación dentro de la misma pantalla ─────────────

  void _move(StudioStep to, int dir, StudioTransition kind) {
    step = to;
    final index = steps.indexOf(to);
    if (index > furthest) furthest = index;
    transition = kind;
    transitionDir = dir;
    transitionTick++;
    notifyListeners();
  }

  /// Avanza a la siguiente sección con su animación propia.
  void next() {
    final list = steps;
    final i = list.indexOf(step);
    if (i < 0 || i >= list.length - 1) return;
    final kind = switch (step) {
      StudioStep.size => StudioTransition.tempIntro,
      StudioStep.base => StudioTransition.tempBurst,
      _ => StudioTransition.plain,
    };
    _move(list[i + 1], 1, kind);
  }

  void back() {
    final list = steps;
    final i = list.indexOf(step);
    if (i > 0) _move(list[i - 1], -1, StudioTransition.plain);
  }

  /// Salta a una sección ya alcanzada (sin perder lo elegido).
  void goToStep(StudioStep target) {
    final list = steps;
    final to = list.indexOf(target), from = list.indexOf(step);
    if (to < 0 || to == from || to > furthest) return;
    _move(target, to > from ? 1 : -1, StudioTransition.plain);
  }

  /// Vuelve a empezar con un vaso vacío.
  void restart() {
    final o = options;
    if (o != null) _applyDefaults(o);
    shots = 0;
    quantity = 1;
    milkLevel = 0.55;
    pour.clear();
    mode = StudioMode.free;
    pour.scoring = false;
    challengeDesign = '';
    cupName = '';
    toppings.clear();
    syrups.clear();
    sweeteners.clear();
    pairings.clear();
    step = StudioStep.size;
    furthest = 0;
    transition = StudioTransition.none;
    notifyListeners();
  }

  /// La etapa actual tiene algo que reiniciar (el resultado no).
  bool get canResetStep => step != StudioStep.result;

  /// Reinicia SOLO la etapa actual; las demás elecciones se conservan.
  void resetCurrentStep() {
    final o = options;
    if (o == null) return;
    switch (step) {
      case StudioStep.size:
        size = _defaultSize(o);
      case StudioStep.base:
        type = _defaultType(o);
        shots = 0;
      case StudioStep.milk:
        milk = _defaultMilk(o);
        milkLevel = 0.55;
      case StudioStep.art:
        pour.clear();
      case StudioStep.toppings:
        toppings.clear();
        syrups.clear();
        sweeteners.clear();
      case StudioStep.result:
        return;
    }
    notifyListeners();
  }

  // ───────────── Recetas ─────────────

  /// Aplica una receta guardada o reciente, ignorando lo que ya no
  /// exista en el menú actual (nunca rompe el estudio).
  void applyRecipe(DrinkRecipe r) {
    // Una receta aplica al recorrido completo: se vuelve al inicio para revisarla.
    step = StudioStep.size;
    final o = options;
    if (o == null) return;
    final c = r.customization;
    if (o.sizes.containsKey(c.size)) size = c.size;
    if (o.types.contains(c.type)) type = c.type;
    if (o.milks.containsKey(c.milk)) milk = c.milk;
    shots = c.extraShots.clamp(0, o.maxExtraShots).toInt();
    milkLevel = r.milkLevel.clamp(0.0, 0.92).toDouble();
    toppings
      ..clear()
      ..addAll(c.toppings.where(o.toppings.containsKey));
    syrups
      ..clear()
      ..addAll(c.syrups.where(o.syrups.containsKey).take(o.maxSyrups));
    sweeteners
      ..clear()
      ..addAll(c.sweeteners.where(o.sweeteners.containsKey).take(o.maxSweeteners));
    final design = canLatteArt && o.latteArtDesigns.contains(c.latteArt) ? c.latteArt : '';
    if (design.isEmpty) {
      pour.clear();
    } else {
      pour.loadCompleted(design);
    }
    cupName = r.name;
    lastRecipe = null;
    furthest = steps.length - 1;
    notifyListeners();
  }

  void offerLastRecipe(DrinkRecipe? r) {
    lastRecipe = r != null && r.available ? r : null;
    notifyListeners();
  }

  void dismissLastRecipe() {
    lastRecipe = null;
    notifyListeners();
  }

  /// Guarda lo preparado como receta (acción voluntaria del usuario).
  Future<String?> saveRecipe(RecipesProvider recipes, {String? name}) =>
      recipes.saveRecipe(product.id, customization, milkLevel, name: name ?? (cupName.trim().isEmpty ? null : cupName.trim()));

  // ───────────── Carrito ─────────────

  /// Agrega la bebida (con su configuración) y los acompañamientos como
  /// líneas reales del carrito. El servidor valida y recalcula todo. Si
  /// la bebida entra, queda registrada como receta reciente.
  Future<StudioAddResult> addToCart(CartProvider cart, RecipesProvider recipes) async {
    adding = true;
    notifyListeners();
    try {
      await cart.addToCart(product, quantity: quantity, customization: customization);
      if (cart.lastAddError != null) {
        return StudioAddResult(drinkAdded: false, error: cart.lastAddError);
      }
      recipes.recordRecent(product.id, customization, milkLevel);
      for (final p in pairings.values) {
        await cart.addToCart(p);
        if (cart.lastAddError != null) {
          return StudioAddResult(
            drinkAdded: true,
            error: 'Tu bebida se agregó, pero ${p.name} no: ${cart.lastAddError}',
          );
        }
      }
      return const StudioAddResult(drinkAdded: true);
    } finally {
      adding = false;
      notifyListeners();
    }
  }
}
