import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/utils/drink_profile.dart';
import '../core/utils/studio_draft.dart';
import '../core/utils/studio_prefs.dart';
import '../models/cup_snapshot.dart';
import '../models/drink_options.dart';
import '../models/drink_recipe.dart';
import '../models/drink_studio_stage.dart';
import '../models/price_quote.dart';
import '../models/product_customization.dart';
import '../models/product_model.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';
import '../widgets/drink_studio/latte_art_shapes.dart';
import '../widgets/drink_studio/latte_pour_session.dart';
import 'cart_provider.dart';

export '../models/price_quote.dart' show PriceLine, PriceQuote;

enum StudioLoad { loading, error, ready }

/// Estado de la compra de la bebida (botón «Comprar latte»).
enum PurchaseStatus { idle, checking, added, error }


/// Estado del estudio de bebidas: UNA sola pantalla donde cada acción
/// actualiza el vaso al instante. Las opciones y precios vienen del
/// backend; los acompañamientos son los postres reales del menú.
class DrinkStudioProvider extends ChangeNotifier {
  /// DrinkStudio prepara un latte y, al terminar, lo vende: el producto
  /// es el latte REAL del menú (lo resuelve el backend en [load]) y el
  /// precio lo calcula el servidor. Mientras no se resuelva (o si el menú
  /// no tiene un latte disponible) el estudio se puede jugar, pero la
  /// compra queda bloqueada con un aviso claro.
  DrinkStudioProvider.latte({this.token})
      : product = Product(
          id: 'drinkstudio-latte',
          name: 'Latte',
          description: '',
          price: 0,
          categoryName: 'Cafés',
        ),
        _catalog = const [] {
    StudioPrefs.instance.addListener(_onPrefs);
    StudioPrefs.instance.load();
  }

  /// Sesión del usuario (para cotizar con sus promociones y comprar).
  String? token;

  void _onPrefs() => notifyListeners();

  /// En el desafío, un diseño terminado puede ser récord.
  void _onArtDone(LattePourSession s) {
    final score = s.score;
    if (mode == StudioMode.challenge && score != null) {
      s.newRecord = StudioPrefs.instance.recordBest(s.design, score.points);
    }
  }

  Product product;
  final List<Product> _catalog;

  /// true cuando [product] es el latte real del menú.
  bool hasRealProduct = false;

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

  /// Porciones por topping (solo para los elegidos; ausente = 1).
  final Map<String, int> toppingQty = {};
  final Set<String> syrups = {};
  final Set<String> sweeteners = {};
  final Map<String, Product> pairings = {};

  // Interfaz
  StudioStep step = StudioStep.temperature;

  /// Sección más avanzada a la que ya llegó (permite volver a las anteriores).
  int furthest = 0;

  // ───────────── Compra ─────────────
  PurchaseStatus purchase = PurchaseStatus.idle;
  String? purchaseMessage;

  /// El error de compra se resuelve iniciando sesión.
  bool purchaseNeedsLogin = false;

  /// Precio por unidad que confirmó el servidor en la última compra.
  double? verifiedUnitPrice;

  /// Aviso (no error) cuando el servidor cotizó distinto a lo mostrado.
  String? priceNotice;

  /// Clave del RepaintBoundary del vaso (para guardar la imagen).
  final GlobalKey artKey = GlobalKey();
  bool get buying => purchase == PurchaseStatus.checking;
  bool get canBuy => hasRealProduct && product.isAvailable && !buying;

  // Transición entre secciones
  StudioTransition transition = StudioTransition.none;
  int transitionTick = 0;

  /// +1 al avanzar (el vaso entra desde la izquierda), -1 al retroceder.
  int transitionDir = 1;

  /// Vertido interactivo del arte latte: diseño elegido (silueta),
  /// leche vertida y progreso. Se conserva al navegar entre etapas.
  late final LattePourSession pour = LattePourSession(onCoarseChange: () => notifyListeners(), onDone: _onArtDone);

  /// Sube cada vez que el usuario completa una etapa avanzando
  /// (dispara el saltito del vaso y el check de la barra de etapas).
  int stepDoneTick = 0;

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
    if (_disposed) return;
    super.notifyListeners();
    _scheduleDraft();
  }

  Timer? _draftTimer;
  bool _draftEnabled = false;

  /// Guarda el borrador (con retraso, para no escribir en cada gesto).
  void _scheduleDraft() {
    if (!_draftEnabled || status != StudioLoad.ready) return;
    _draftTimer?.cancel();
    _draftTimer = Timer(const Duration(milliseconds: 700), () {
      if (_disposed || !hasProgress) return;
      StudioDraft.save(draftJson());
    });
  }

  /// Lo necesario para reconstruir la bebida (formato de la API).
  Map<String, dynamic> draftJson() => {
        'customization': customization.toJson(),
        'milkLevel': milkLevel,
        'cupName': cupName,
        'artDone': pour.completed ? pour.design : '',
        'step': step.name,
      };

  /// ¿Hay un borrador guardado que ofrecer? (null si no)
  Future<Map<String, dynamic>?> pendingDraft() => StudioDraft.load();

  /// Aplica el borrador que el usuario autorizó retomar.
  void resumeDraft(Map<String, dynamic> d) {
    final o = options;
    if (o == null) return;
    final custom = ProductCustomization.fromJson(d['customization'] is Map ? Map<String, dynamic>.from(d['customization'] as Map) : null);
    final art = d['artDone']?.toString() ?? '';
    _applySelection(
      custom.copyWith(latteArt: art),
      ((d['milkLevel'] as num?)?.toDouble() ?? 0.55).clamp(0.0, 0.92).toDouble(),
      d['cupName']?.toString() ?? '',
    );
    final saved = StudioStep.values.where((e) => e.name == d['step']).firstOrNull;
    final list = steps;
    if (saved != null && list.contains(saved) && saved != StudioStep.result) {
      step = saved;
      furthest = list.indexOf(saved);
    }
    notifyListeners();
  }

  /// Empezar de cero descarta el borrador.
  Future<void> discardDraft() => StudioDraft.clear();

  @override
  void dispose() {
    _draftTimer?.cancel();
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
      await _resolveProduct();
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
      _draftEnabled = true;
    } on ApiException catch (e) {
      error = e.message;
      status = StudioLoad.error;
    } catch (_) {
      error = 'No pudimos cargar las opciones de tu bebida.';
      status = StudioLoad.error;
    }
    notifyListeners();
  }

  /// Carga opciones y producto sin red (pruebas).
  @visibleForTesting
  void debugLoad(DrinkOptions loaded, {Product? latte}) {
    if (latte != null) {
      product = latte;
      hasRealProduct = true;
    }
    loaded.register();
    options = loaded;
    profile = DrinkProfile.of(product, loaded);
    _applyDefaults(loaded);
    status = StudioLoad.ready;
    notifyListeners();
  }

  /// Busca el latte real del menú. Si el servidor no lo encuentra, el
  /// estudio sigue funcionando pero sin poder comprar.
  Future<void> _resolveProduct() async {
    try {
      final data = await ApiClient.get('/customization/drinkstudio/product', token: token);
      final raw = data['product'];
      if (raw is Map<String, dynamic>) {
        final price = (raw['price'] as num?)?.toDouble() ?? 0;
        final discount = (raw['discountPerUnit'] as num?)?.toDouble() ?? 0;
        final images = (raw['images'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];
        product = Product(
          id: raw['id'].toString(),
          name: (raw['name'] as String?) ?? 'Latte',
          description: (raw['description'] as String?) ?? '',
          price: price,
          images: images,
          isAvailable: raw['isAvailable'] != false,
          categoryName: raw['categoryName'] as String?,
          discountedPrice: discount > 0 ? price - discount : null,
          promotionName: raw['promotionName'] as String?,
        );
        hasRealProduct = true;
        return;
      }
    } on ApiException catch (e) {
      if (e.isNetworkError) rethrow;
    }
    hasRealProduct = false;
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
  bool get hasMilk => milkLevel >= 0.2;

  /// El arte latte necesita bebida caliente, espuma de leche y algo de
  /// leche en el vaso (sin leche no hay sobre qué dibujar).
  bool get canLatteArt => (profile?.supportsLatteArt ?? false) && isHot && hasMilk;

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
      StudioStep.temperature,
      StudioStep.base,
      StudioStep.milk,
      if (canLatteArt && o.latteArtDesigns.isNotEmpty) StudioStep.art,
      if (availableToppings.isNotEmpty || o.hasSyrups || o.hasSweeteners) StudioStep.toppings,
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
        StudioStep.result => resultTop ? CupView.top : CupView.side,
        _ => CupView.side,
      };

  bool? _resultTop;

  /// En el resultado: vista desde arriba si hay arte o toppings que lucir
  /// (el usuario puede alternar).
  bool get resultTop => _resultTop ?? (latteArt.isNotEmpty || toppings.isNotEmpty || sweeteners.isNotEmpty);

  void setResultTop(bool v) {
    _resultTop = v;
    notifyListeners();
  }

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
        toppingQuantities: {for (final t in toppings) t: toppingQty[t] ?? 1},
        syrups: Set<String>.from(syrups),
        sweeteners: Set<String>.from(sweeteners),
        latteArt: latteArt,
      );

  /// Toppings que de verdad van con esta bebida y esta temperatura.
  Map<String, double> get availableToppings => options?.toppingsFor('${product.name} ${product.categoryName ?? ''}', type) ?? const {};

  /// Precio de UNA bebida con todo su desglose: base, ajuste de tamaño,
  /// adicionales y descuento. Mismo cálculo que el backend.
  PriceQuote get quote => customization.quote(basePrice: product.price, effectivePrice: product.effectivePrice, promotionName: product.promotionName);

  /// Adicionales con precio (leche, shots, toppings...), sin el tamaño.
  List<PriceLine> get priceLines => quote.lines;

  /// Ajuste por tamaño (Pequeño -3.000 · Mediano 0 · Grande +5.000).
  double get sizeAdjustment => quote.sizeAdjustment;

  /// Lo que suma la personalización por unidad (tamaño + adicionales).
  double get extraPerUnit => quote.customizationPrice;

  /// Descuento de promoción por unidad.
  double get discountPerUnit => quote.discountPerUnit;

  double get unitPrice => quote.unitPrice;
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
        toppingQty: {for (final t in toppings) t: toppingQty[t] ?? 1},
        syrups: syrups.toList()..sort(),
        sweeteners: sweeteners.toList()..sort(),
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
    // Un topping que no va con la nueva temperatura (p. ej. malvaviscos
    // en frío) se retira para no pedir algo que el servidor rechazaría.
    final ok = availableToppings.keys.toSet();
    for (final t in toppings.toList()) {
      if (!ok.contains(t)) {
        toppings.remove(t);
        toppingQty.remove(t);
      }
    }
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

  /// Tocar la tarjeta: añade 1 porción o retira el topping completo.
  bool toggleTopping(String n) {
    if (!toppings.contains(n) && !availableToppings.containsKey(n)) return false;
    if (toppings.remove(n)) {
      toppingQty.remove(n);
    } else {
      toppings.add(n);
      toppingQty[n] = 1;
      _pour(PourKind.topping);
    }
    notifyListeners();
    return true;
  }

  int toppingQuantity(String n) => toppings.contains(n) ? (toppingQty[n] ?? 1) : 0;

  /// Suma o resta porciones de [n]. Al llegar a 0 se retira. Devuelve
  /// false si se pasa del máximo que acepta el servidor.
  bool changeToppingQuantity(String n, int delta) {
    final max = options?.maxToppingQuantity ?? ProductCustomization.maxToppingQuantity;
    final next = toppingQuantity(n) + delta;
    if (next > max) return false;
    if (next <= 0) {
      toppings.remove(n);
      toppingQty.remove(n);
    } else {
      toppings.add(n);
      toppingQty[n] = next;
      if (delta > 0) _pour(PourKind.topping);
    }
    notifyListeners();
    return true;
  }
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
    if (status == StudioLoad.ready) _draftEnabled = true;
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
    stepDoneTick++;
    final kind = switch (step) {
      StudioStep.temperature => StudioTransition.tempBurst,
      _ => StudioTransition.plain,
    };
    _move(list[i + 1], 1, kind);
  }

  void back() {
    final list = steps;
    final i = list.indexOf(step);
    if (i > 0) {
      final to = list[i - 1];
      _move(to, -1, to == StudioStep.temperature ? StudioTransition.tempIntro : StudioTransition.plain);
    }
  }

  /// Salta a una sección ya alcanzada (sin perder lo elegido).
  void goToStep(StudioStep target) {
    final list = steps;
    final to = list.indexOf(target), from = list.indexOf(step);
    if (to < 0 || to == from || to > furthest) return;
    _move(target, to > from ? 1 : -1, target == StudioStep.temperature ? StudioTransition.tempIntro : StudioTransition.plain);
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
    toppingQty.clear();
    syrups.clear();
    sweeteners.clear();
    pairings.clear();
    step = StudioStep.temperature;
    furthest = 0;
    _resultTop = null;
    purchase = PurchaseStatus.idle;
    purchaseMessage = null;
    priceNotice = null;
    transition = StudioTransition.none;
    StudioDraft.clear();
    _draftEnabled = status == StudioLoad.ready;
    notifyListeners();
  }

  /// La etapa actual tiene algo que reiniciar (el resultado no).
  bool get canResetStep => step != StudioStep.result;

  /// Reinicia SOLO la etapa actual; las demás elecciones se conservan.
  void resetCurrentStep() {
    final o = options;
    if (o == null) return;
    switch (step) {
      case StudioStep.temperature:
        setType(_defaultType(o));
        return;
      case StudioStep.base:
        size = _defaultSize(o);
        shots = 0;
      case StudioStep.milk:
        milk = _defaultMilk(o);
        milkLevel = 0.55;
      case StudioStep.art:
        pour.clear();
      case StudioStep.toppings:
        toppings.clear();
        toppingQty.clear();
        syrups.clear();
        sweeteners.clear();
      case StudioStep.result:
        return;
    }
    notifyListeners();
  }

  // ───────────── Compra ─────────────

  /// Convierte la bebida en una línea REAL del carrito:
  ///  1. el servidor valida la configuración y cotiza (reglas centrales);
  ///  2. la línea se agrega con el CartProvider de siempre, enviando el
  ///     importe cotizado para que el servidor lo vuelva a verificar.
  /// Nunca simula un pago: después se sigue el flujo normal del carrito.
  /// Devuelve true si la bebida quedó en el carrito.
  Future<bool> buy(CartProvider cart) async {
    if (buying) return false; // evita dobles envíos
    purchaseNeedsLogin = false;
    priceNotice = null;

    if (!hasRealProduct || !product.isAvailable) {
      return _fail('El latte no está disponible por ahora. Tu bebida queda guardada para cuando vuelva.');
    }
    if (token == null) {
      purchaseNeedsLogin = true;
      return _fail('Inicia sesión para comprar tu latte. Tu bebida se conserva.');
    }

    purchase = PurchaseStatus.checking;
    purchaseMessage = null;
    notifyListeners();

    final local = customization;
    final localUnit = unitPrice;
    try {
      final data = await ApiClient.post('/customization/drinkstudio/quote', token: token, body: {
        'productId': product.id,
        'quantity': quantity,
        'customization': local.toJson(),
        'milkLevel': milkLevel,
      });
      final raw = data['quote'];
      if (raw is! Map<String, dynamic>) throw ApiException('Respuesta inesperada del servidor');

      final verified = ProductCustomization.fromJson(raw['customization'] is Map ? Map<String, dynamic>.from(raw['customization'] as Map) : null);
      final serverUnit = (raw['unitPrice'] as num).toDouble();
      verifiedUnitPrice = serverUnit;
      if ((serverUnit - localUnit).abs() >= 0.5) {
        priceNotice = 'El precio oficial de tu bebida es ${_money(serverUnit)} por unidad.';
      }

      await cart.addToCart(
        product,
        quantity: quantity,
        customization: verified,
        source: 'drinkstudio',
        expectedUnitPrice: serverUnit,
      );
      final rejected = cart.lastAddError;
      if (rejected != null) return _fail(rejected);

      purchase = PurchaseStatus.added;
      purchaseMessage = '¡Tu latte está en el carrito!';
      // Ya se compró: no se vuelve a ofrecer como "latte a medias" hasta
      // que el usuario edite o reinicie.
      _draftEnabled = false;
      _draftTimer?.cancel();
      StudioDraft.clear();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      final msg = switch (e.statusCode) {
        null => 'No pudimos conectarnos. Revisa tu internet; tu bebida sigue aquí.',
        404 || 409 => e.message.isNotEmpty ? e.message : 'El latte ya no está disponible.',
        400 => 'Esta combinación no se puede preparar: ${e.message}',
        401 => 'Tu sesión venció. Inicia sesión de nuevo; tu bebida se conserva.',
        _ => e.message,
      };
      if (e.statusCode == 401) purchaseNeedsLogin = true;
      return _fail(msg);
    } catch (_) {
      return _fail('No pudimos preparar tu pedido. Inténtalo de nuevo.');
    }
  }

  bool _fail(String message) {
    purchase = PurchaseStatus.error;
    purchaseMessage = message;
    notifyListeners();
    return false;
  }

  /// El usuario vio el resultado de la compra (o volvió a editar).
  void clearPurchaseStatus() {
    if (purchase == PurchaseStatus.idle) return;
    purchase = PurchaseStatus.idle;
    purchaseMessage = null;
    purchaseNeedsLogin = false;
    notifyListeners();
  }

  static String _money(double v) {
    final n = v.round().toString();
    final b = StringBuffer();
    for (var i = 0; i < n.length; i++) {
      if (i > 0 && (n.length - i) % 3 == 0) b.write('.');
      b.write(n[i]);
    }
    return '\$$b';
  }

  // ───────────── Recetas ─────────────

  /// Aplica una receta guardada o reciente, ignorando lo que ya no
  /// exista en el menú actual (nunca rompe el estudio).
  void applyRecipe(DrinkRecipe r) {
    // Una receta aplica al recorrido completo: se vuelve al inicio para revisarla.
    step = StudioStep.temperature;
    final o = options;
    if (o == null) return;
    _applySelection(r.customization, r.milkLevel, r.name);
    lastRecipe = null;
    furthest = steps.length - 1;
    notifyListeners();
  }

  /// Aplica una configuración ignorando lo que ya no exista en el menú.
  void _applySelection(ProductCustomization c, double level, String name) {
    final o = options;
    if (o == null) return;
    if (o.sizes.containsKey(c.size)) size = c.size;
    if (o.types.contains(c.type)) type = c.type;
    if (o.milks.containsKey(c.milk)) milk = c.milk;
    shots = c.extraShots.clamp(0, o.maxExtraShots).toInt();
    milkLevel = level.clamp(0.0, 0.92).toDouble();
    toppings
      ..clear()
      ..addAll(c.toppings.where(o.toppings.containsKey));
    toppingQty
      ..clear()
      ..addAll({
        for (final t in toppings) t: c.quantityOf(t).clamp(1, o.maxToppingQuantity).toInt(),
      });
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
    cupName = name;
  }

  void offerLastRecipe(DrinkRecipe? r) {
    lastRecipe = r != null && r.available ? r : null;
    notifyListeners();
  }

  void dismissLastRecipe() {
    lastRecipe = null;
    notifyListeners();
  }
}
