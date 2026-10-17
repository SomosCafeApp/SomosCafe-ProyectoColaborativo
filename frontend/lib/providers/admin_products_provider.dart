import 'package:flutter/material.dart';

import '../models/picked_image.dart';
import '../models/product_model.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';

/// Filtro por visibilidad en el menú.
enum ProductVisibilityFilter { all, visible, hidden }

extension ProductVisibilityFilterX on ProductVisibilityFilter {
  String get label {
    switch (this) {
      case ProductVisibilityFilter.all:
        return 'Todos';
      case ProductVisibilityFilter.visible:
        return 'Visibles';
      case ProductVisibilityFilter.hidden:
        return 'Ocultos';
    }
  }
}

/// CRUD de productos para el panel admin (rutas protegidas con adminOnly).
///   GET    /products/admin/all   → todos, incluidos los ocultos
///   POST   /products             → multipart (imagen → Cloudinary)
///   PUT    /products/:id         → multipart, o JSON para ocultar/mostrar
///   DELETE /products/:id         → borrado definitivo
class AdminProductsProvider extends ChangeNotifier {
  List<Product> _products = [];
  String? _token;
  bool _isAdmin = false;

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _busyProductId;
  String _searchQuery = '';
  ProductVisibilityFilter _visibilityFilter = ProductVisibilityFilter.all;
  String? _categoryFilter;

  // Resultado de filtrar, guardado hasta que cambie la lista o un filtro:
  // la UI lo consulta en cada reconstrucción y recalcularlo con muchos
  // productos era el cuello de botella.
  List<Product>? _filteredCache;

  void _invalidateFilter() => _filteredCache = null;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get busyProductId => _busyProductId;
  String get searchQuery => _searchQuery;

  ProductVisibilityFilter get visibilityFilter => _visibilityFilter;
  String? get categoryFilter => _categoryFilter;

  /// Productos tras aplicar búsqueda, visibilidad y categoría.
  List<Product> get filteredProducts => _filteredCache ??= _computeFiltered();

  List<Product> _computeFiltered() {
    final query = _searchQuery.trim().toLowerCase();

    return _products.where((p) {
      switch (_visibilityFilter) {
        case ProductVisibilityFilter.visible:
          if (!p.isAvailable) return false;
        case ProductVisibilityFilter.hidden:
          if (p.isAvailable) return false;
        case ProductVisibilityFilter.all:
          break;
      }

      if (_categoryFilter != null && p.categoryId != _categoryFilter) return false;

      if (query.isEmpty) return true;
      return '${p.name} ${p.categoryName ?? ''}'.toLowerCase().contains(query);
    }).toList();
  }

  int countFor(ProductVisibilityFilter filter) {
    switch (filter) {
      case ProductVisibilityFilter.all:
        return _products.length;
      case ProductVisibilityFilter.visible:
        return _products.where((p) => p.isAvailable).length;
      case ProductVisibilityFilter.hidden:
        return _products.where((p) => !p.isAvailable).length;
    }
  }

  /// Categorías que realmente tienen productos (id → nombre), para los chips.
  Map<String, String> get categoryOptions {
    final result = <String, String>{};
    for (final p in _products) {
      final id = p.categoryId;
      final name = p.categoryName;
      if (id != null && name != null && name.isNotEmpty) result[id] = name;
    }
    return result;
  }

  int countForCategory(String categoryId) => _products.where((p) => p.categoryId == categoryId).length;

  bool get _canUse => _token != null && _isAdmin;

  void updateAuth(String? token, bool isAdmin) {
    _token = token;
    _isAdmin = isAdmin;

    if ((token == null || !isAdmin) && _products.isNotEmpty) {
      _products = [];
      _errorMessage = null;
      _searchQuery = '';
      _visibilityFilter = ProductVisibilityFilter.all;
      _categoryFilter = null;
      _invalidateFilter();
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    if (query == _searchQuery) return;
    _searchQuery = query;
    _invalidateFilter();
    notifyListeners();
  }

  void setVisibilityFilter(ProductVisibilityFilter filter) {
    _visibilityFilter = filter;
    _invalidateFilter();
    notifyListeners();
  }

  /// Tocar la categoría ya seleccionada quita el filtro.
  void toggleCategoryFilter(String categoryId) {
    _categoryFilter = _categoryFilter == categoryId ? null : categoryId;
    _invalidateFilter();
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    if (!_canUse) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await ApiClient.get('/products/admin/all', token: _token);
      final raw = data['products'] as List? ?? [];
      _products = raw.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
      _invalidateFilter();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, String> _fields({
    required String name,
    required String description,
    required double price,
    required String ingredients,
    required String? categoryId,
    bool? isAvailable,
  }) =>
      {
        'name': name.trim(),
        'description': description.trim(),
        'price': price.toStringAsFixed(0),
        // Texto libre separado por comas; el backend lo convierte en lista.
        'ingredients': ingredients.trim(),
        'categoryId': categoryId ?? '',
        if (isAvailable != null) 'isAvailable': isAvailable.toString(),
      };

  /// Crea un producto. La imagen es obligatoria al crear.
  Future<bool> createProduct({
    required String name,
    required String description,
    required double price,
    required String ingredients,
    required String? categoryId,
    required bool isAvailable,
    required PickedImage image,
  }) {
    return _submit(() => ApiClient.sendMultipart(
          'POST',
          '/products',
          token: _token,
          fields: _fields(
            name: name,
            description: description,
            price: price,
            ingredients: ingredients,
            categoryId: categoryId,
            isAvailable: isAvailable,
          ),
          imageBytes: image.bytes,
          imageName: image.name,
        ));
  }

  /// Edita un producto. [image] solo se envía si se eligió una nueva.
  Future<bool> updateProduct(
    String id, {
    required String name,
    required String description,
    required double price,
    required String ingredients,
    required String? categoryId,
    PickedImage? image,
  }) {
    return _submit(() => ApiClient.sendMultipart(
          'PUT',
          '/products/$id',
          token: _token,
          fields: _fields(
            name: name,
            description: description,
            price: price,
            ingredients: ingredients,
            categoryId: categoryId,
          ),
          imageBytes: image?.bytes,
          imageName: image?.name,
        ));
  }

  Future<bool> _submit(Future<Map<String, dynamic>> Function() request) async {
    if (!_canUse) return false;
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await request();
      await fetchProducts();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Oculta (false) o vuelve a mostrar (true) el producto en el menú.
  /// No lo borra: el historial de pedidos y favoritos se mantiene.
  Future<bool> setAvailability(String id, bool isAvailable) {
    return _runBusy(id, () async {
      await ApiClient.put('/products/$id', token: _token, body: {'isAvailable': isAvailable});

      // Se actualiza solo ese producto en memoria: volver a descargar
      // toda la lista por cambiar un interruptor era lo más lento.
      _products = [
        for (final p in _products) p.id == id ? p.copyWith(isAvailable: isAvailable) : p,
      ];
      _invalidateFilter();
    });
  }

  /// Borrado definitivo. El backend también lo saca de carritos,
  /// favoritos, reseñas, inventario y promociones; los pedidos ya
  /// hechos se conservan con su propia copia del producto.
  Future<bool> deleteProduct(String id) {
    return _runBusy(id, () async {
      await ApiClient.delete('/products/$id', token: _token);

      _products = _products.where((p) => p.id != id).toList();

      // Si era el último de la categoría filtrada, se quita el filtro
      // (su chip desaparece y la lista quedaría vacía sin salida).
      if (_categoryFilter != null && !_products.any((p) => p.categoryId == _categoryFilter)) {
        _categoryFilter = null;
      }
      _invalidateFilter();
    });
  }

  Future<bool> _runBusy(String id, Future<void> Function() action) async {
    if (!_canUse) return false;
    _busyProductId = id;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _busyProductId = null;
      notifyListeners();
    }
  }
}
