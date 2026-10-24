import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/utils/drink_profile.dart';
import '../models/cup_snapshot.dart';
import '../models/drink_options.dart';
import '../models/drink_recipe.dart';
import '../models/drink_studio_stage.dart';
import '../models/product_customization.dart';
import '../models/product_model.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';
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
  DrinkStudioProvider({required this.product, required List<Product> catalog}) : _catalog = catalog;

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
  double mix = 0;
  String latteArt = '';
  final Set<String> toppings = {};
  final Set<String> syrups = {};
  final Set<String> sweeteners = {};
  final Map<String, Product> pairings = {};

  // Interfaz
  StudioStage tab = StudioStage.size;
  final Set<StudioStage> visited = {StudioStage.size};
  bool showSummary = false;
  bool adding = false;
  double? spoon;

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

  void _applyDefaults(DrinkOptions o) {
    size = o.sizes.containsKey(o.defaultSize) ? o.defaultSize : o.sizes.keys.first;
    type = o.types.contains(o.defaultType) ? o.defaultType : o.types.first;
    milk = o.milks.containsKey(o.defaultMilk) ? o.defaultMilk : o.milks.keys.first;
  }

  // ───────────── Datos derivados ─────────────

  bool get isHot => type == ProductCustomization.defaultType;
  bool get canLatteArt => (profile?.supportsLatteArt ?? false) && isHot;
  bool get isCoffee => profile?.isCoffee ?? false;

  /// Postres reales disponibles para acompañar.
  List<Product> get availablePairings =>
      _catalog.where((p) => p.isAvailable && !p.isCustomizable && p.id != product.id).toList();

  /// Pestañas de la bandeja de control (según datos reales y tipo de bebida).
  List<StudioStage> get tabs {
    final o = options;
    if (o == null) return const [];
    return [
      StudioStage.size,
      StudioStage.base,
      StudioStage.milk,
      if (o.hasSyrups) StudioStage.syrups,
      if (o.hasSweeteners) StudioStage.sweeteners,
      if (o.toppings.isNotEmpty) StudioStage.toppings,
      if (canLatteArt && o.latteArtDesigns.isNotEmpty) StudioStage.latteArt,
      if (availablePairings.isNotEmpty) StudioStage.pairing,
    ];
  }

  /// Fracción de pestañas que el usuario ya visitó.
  double get progress {
    final list = tabs;
    if (list.isEmpty) return 0;
    return list.where(visited.contains).length / list.length;
  }

  int? get ounces => options?.ouncesOf(size);

  /// Escala del vaso: alto y ancho crecen juntos, así el volumen
  /// visual sigue a las onzas (referencia: 12 oz).
  double get sizeFactor {
    final oz = ounces;
    if (oz != null && oz > 0) return math.pow(oz / 12, 0.45).toDouble();
    final keys = options?.sizes.keys.toList() ?? const <String>[];
    final i = keys.indexOf(size);
    return keys.length < 2 || i < 0 ? 1.0 : 0.85 + 0.3 * i / (keys.length - 1);
  }

  /// Ya hay algo preparado (para confirmar antes de salir).
  bool get hasProgress => !customization.isDefault || pairings.isNotEmpty || mix > 0;

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
        mix: mix,
        toppings: toppings.toList()..sort(),
        syrups: syrups.toList()..sort(),
        sweeteners: sweeteners.length,
        latteArt: canLatteArt ? latteArt : '',
        spoon: spoon,
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
    if (!canLatteArt) latteArt = '';
    if (!tabs.contains(tab)) tab = StudioStage.base;
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

  void setLatteArt(String design) {
    latteArt = latteArt == design ? '' : design;
    notifyListeners();
  }

  // ───────────── Mezcla ─────────────

  void setSpoon(double? depth) {
    spoon = depth;
    notifyListeners();
  }

  void addMix(double delta) {
    mix = (mix + delta).clamp(0.0, 1.0).toDouble();
    notifyListeners();
  }

  // ───────────── Acompañamientos ─────────────

  void togglePairing(Product p) {
    if (pairings.remove(p.id) == null) pairings[p.id] = p;
    notifyListeners();
  }

  // ───────────── Navegación dentro de la misma pantalla ─────────────

  void goTo(StudioStage s) {
    tab = s;
    visited.add(s);
    notifyListeners();
  }

  void openSummary() {
    showSummary = true;
    notifyListeners();
  }

  void closeSummary() {
    showSummary = false;
    notifyListeners();
  }

  /// Vuelve a empezar con un vaso vacío.
  void restart() {
    final o = options;
    if (o != null) _applyDefaults(o);
    shots = 0;
    quantity = 1;
    milkLevel = 0.55;
    mix = 0;
    latteArt = '';
    spoon = null;
    toppings.clear();
    syrups.clear();
    sweeteners.clear();
    pairings.clear();
    tab = StudioStage.size;
    visited
      ..clear()
      ..add(StudioStage.size);
    showSummary = false;
    notifyListeners();
  }

  // ───────────── Recetas ─────────────

  /// Aplica una receta guardada o reciente, ignorando lo que ya no
  /// exista en el menú actual (nunca rompe el estudio).
  void applyRecipe(DrinkRecipe r) {
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
    latteArt = canLatteArt && o.latteArtDesigns.contains(c.latteArt) ? c.latteArt : '';
    mix = 0;
    lastRecipe = null;
    visited.addAll(tabs);
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
      recipes.saveRecipe(product.id, customization, milkLevel, name: name);

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
