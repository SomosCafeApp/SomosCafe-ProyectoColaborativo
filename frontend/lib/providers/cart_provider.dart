import 'package:flutter/material.dart';

import '../models/product_customization.dart';
import '../models/product_model.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';

/// Una línea del carrito: producto + personalización + cantidad.
/// El mismo producto con personalizaciones distintas son líneas
/// distintas; si producto y personalización coinciden, se acumula
/// la cantidad en la misma línea.
class CartLine {
  /// _id de la línea en el backend (en modo invitado es un id local).
  final String id;
  final Product product;
  final int quantity;
  final ProductCustomization customization;

  /// Precio por unidad ANTES de descuento (base + personalización).
  final double originalUnitPrice;

  /// Descuento de la promoción vigente, por unidad (sobre el precio base).
  final double discountPerUnit;

  /// Nombre de la promoción aplicada (null si no hay).
  final String? promotionName;

  /// false si el admin ocultó el producto del menú después de que el
  /// usuario lo agregara: no se puede pedir hasta quitarlo del carrito.
  final bool isAvailable;

  CartLine({
    required this.id,
    required this.product,
    required this.quantity,
    required this.customization,
    required this.originalUnitPrice,
    this.discountPerUnit = 0,
    this.promotionName,
    this.isAvailable = true,
  });

  /// Precio por unidad ya con descuento. Cuando viene del servidor es
  /// el valor oficial; en el modo optimista local es una estimación que
  /// el servidor corrige en cuanto responde.
  double get unitPrice => originalUnitPrice - discountPerUnit;

  double get lineSubtotal => originalUnitPrice * quantity;
  double get lineDiscount => discountPerUnit * quantity;
  double get lineTotal => unitPrice * quantity;
  bool get hasDiscount => discountPerUnit > 0;

  CartLine copyWith({int? quantity}) => CartLine(
        id: id,
        product: product,
        quantity: quantity ?? this.quantity,
        customization: customization,
        originalUnitPrice: originalUnitPrice,
        discountPerUnit: discountPerUnit,
        promotionName: promotionName,
        isAvailable: isAvailable,
      );

  bool matches(Product other, ProductCustomization otherCustomization) =>
      product.id == other.id && customization.key == otherCustomization.key;
}

/// Carrito conectado al backend (GET/POST/PUT/DELETE /api/cart).
///
/// Mientras no hay sesión, funciona en memoria (carrito de invitado)
/// para no romper la experiencia de navegar el menú sin loguearse.
/// En cuanto el usuario inicia sesión, [updateAuth] dispara la carga
/// del carrito real guardado en la base de datos.
class CartProvider extends ChangeNotifier {
  List<CartLine> _lines = [];
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;
  String? _lastAddError;

  /// Mensaje del servidor si la última alta al carrito fue rechazada
  /// (null si salió bien). Lo usa el estudio de bebidas, que necesita
  /// saber si la configuración fue aceptada.
  String? get lastAddError => _lastAddError;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<CartLine> get lines => _lines;

  /// Cantidad total de unidades en el carrito.
  int get itemCount => _lines.fold(0, (sum, l) => sum + l.quantity);

  bool get isEmpty => _lines.isEmpty;

  /// Hay productos en el carrito que ya no están en el menú.
  bool get hasUnavailableLines => _lines.any((l) => !l.isAvailable);

  /// Antes de descuentos.
  double get subtotal => _lines.fold(0.0, (sum, l) => sum + l.lineSubtotal);

  /// Ahorro total por promociones.
  double get discount => _lines.fold(0.0, (sum, l) => sum + l.lineDiscount);

  /// Productos con descuento (subtotal - descuento). El envío se suma
  /// aparte, en la confirmación del pedido.
  double get total => subtotal - discount;

  /// Llamado por el ChangeNotifierProxyProvider cada vez que cambia
  /// la sesión (login, logout o restauración automática al abrir la app).
  void updateAuth(String? token) {
    final wasLoggedIn = _token != null;
    _token = token;

    if (token != null && !wasLoggedIn) {
      fetchCart();
    } else if (token == null && wasLoggedIn) {
      _lines = [];
      notifyListeners();
    }
  }

  List<CartLine> _parseCart(Map<String, dynamic> cart) {
    final rawItems = cart['items'] as List? ?? [];
    return rawItems.where((i) => i['productId'] is Map).map((i) {
      final product = Product.fromJson(i['productId'] as Map<String, dynamic>);
      final customization = ProductCustomization.fromJson(i['customization'] as Map<String, dynamic>?);
      final promotion = i['promotion'];
      return CartLine(
        id: (i['_id'] ?? '').toString(),
        product: product,
        quantity: (i['quantity'] as num).toInt(),
        customization: customization,
        originalUnitPrice:
            (i['originalUnitPrice'] as num?)?.toDouble() ?? (product.price + customization.extraPrice),
        discountPerUnit: (i['discountPerUnit'] as num?)?.toDouble() ?? 0,
        promotionName: promotion is Map<String, dynamic> ? promotion['name'] as String? : null,
        isAvailable: i['isAvailable'] != false,
      );
    }).toList();
  }

  Future<void> fetchCart() async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiClient.get('/cart', token: _token);
      _lines = _parseCart(data['cart'] as Map<String, dynamic>);
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _addLocal(Product product, int quantity, ProductCustomization customization) {
    final idx = _lines.indexWhere((l) => l.matches(product, customization));
    if (idx >= 0) {
      _lines[idx] = _lines[idx].copyWith(quantity: _lines[idx].quantity + quantity);
    } else {
      _lines.add(CartLine(
        id: 'local_${product.id}_${customization.key}',
        product: product,
        quantity: quantity,
        customization: customization,
        // Estimación optimista: el servidor devuelve el valor oficial.
        originalUnitPrice: product.price + customization.extraPrice,
        discountPerUnit: product.hasDiscount ? product.price - product.effectivePrice : 0,
        promotionName: product.promotionName,
      ));
    }
    notifyListeners();
  }

  /// Altas pendientes de confirmar en el servidor y cola que las ejecuta
  /// de una en una. Sin esto, "Pedir de nuevo" lanzaba varios POST en
  /// paralelo y cada respuesta pisaba el carrito con una foto parcial
  /// (o llegaba desordenada), dejando la vista desactualizada hasta que
  /// otra acción la recargaba.
  int _pendingAdds = 0;
  Future<void> _addQueue = Future.value();

  /// Agrega un producto con su personalización. Misma combinación →
  /// suma cantidad; combinación distinta → línea nueva.
  Future<void> addToCart(
    Product product, {
    int quantity = 1,
    ProductCustomization? customization,
  }) {
    final custom = customization ?? ProductCustomization();

    // Actualización optimista: se ve al instante en la UI.
    _addLocal(product, quantity, custom);

    if (_token == null) return Future.value(); // invitado: solo memoria local

    _pendingAdds++;
    final task = _addQueue
        .catchError((_) {})
        .then((_) => _syncAdd(product, quantity, custom));
    _addQueue = task;
    return task;
  }

  /// Envía un alta al servidor. Solo la última de la cola reemplaza el
  /// carrito con la respuesta del servidor (que ya incluye todas las
  /// anteriores); las intermedias conservan el estado optimista.
  Future<void> _syncAdd(
    Product product,
    int quantity,
    ProductCustomization custom,
  ) async {
    var failed = false;
    _lastAddError = null;
    try {
      final data = await ApiClient.post('/cart/items', token: _token, body: {
        'productId': product.id,
        'quantity': quantity,
        'customization': custom.toJson(),
      });
      if (_pendingAdds == 1) {
        _lines = _parseCart(data['cart'] as Map<String, dynamic>);
        notifyListeners();
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _lastAddError = e.message;
      failed = true;
    } finally {
      _pendingAdds--;
    }

    // Si falló la última de la cola, revertimos al estado real del servidor.
    if (failed && _pendingAdds == 0) await fetchCart();
  }

  /// Suma una unidad a una línea existente (botón "+").
  Future<void> incrementLine(CartLine line) =>
      addToCart(line.product, quantity: 1, customization: line.customization);

  /// Resta una unidad a la línea (botón "-"). Si quedara en 0, la quita.
  Future<void> removeSingleItem(CartLine line) async {
    final idx = _lines.indexWhere((l) => l.id == line.id);
    if (idx < 0) return;

    final newQty = _lines[idx].quantity - 1;

    if (_token == null) {
      if (newQty <= 0) {
        _lines.removeAt(idx);
      } else {
        _lines[idx] = _lines[idx].copyWith(quantity: newQty);
      }
      notifyListeners();
      return;
    }

    try {
      final Map<String, dynamic> data;
      if (newQty <= 0) {
        data = await ApiClient.delete('/cart/items/${line.id}', token: _token);
      } else {
        data = await ApiClient.put('/cart/items/${line.id}', token: _token, body: {
          'quantity': newQty,
        });
      }
      _lines = _parseCart(data['cart'] as Map<String, dynamic>);
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      await fetchCart();
    }
  }

  /// Quita toda la línea (sin importar la cantidad) — botón de eliminar.
  Future<void> removeLine(CartLine line) async {
    final idx = _lines.indexWhere((l) => l.id == line.id);
    if (idx < 0) return;

    if (_token == null) {
      _lines.removeAt(idx);
      notifyListeners();
      return;
    }

    // Actualización optimista.
    final backup = List<CartLine>.from(_lines);
    _lines.removeAt(idx);
    notifyListeners();

    try {
      final data = await ApiClient.delete('/cart/items/${line.id}', token: _token);
      _lines = _parseCart(data['cart'] as Map<String, dynamic>);
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _lines = backup;
      notifyListeners();
    }
  }

  /// Vacía el carrito (botón "Vaciar").
  Future<void> clearCart() async {
    _lines = [];
    notifyListeners();

    if (_token == null) return;

    try {
      await ApiClient.delete('/cart', token: _token);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    }
  }

  /// Vacía solo la copia local. Se usa después de crear un pedido: el
  /// backend ya vació el carrito del servidor al crear la orden, así
  /// que no hace falta otra llamada.
  void clearLocal() {
    _lines = [];
    notifyListeners();
  }
}
