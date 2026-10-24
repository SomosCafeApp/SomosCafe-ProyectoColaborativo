import 'package:flutter/material.dart';

import '../models/drink_recipe.dart';
import '../models/product_customization.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';

/// Recetas del estudio de bebidas, conectadas a /api/recipes.
/// - Recientes: se registran solas al agregar una bebida al carrito.
/// - Guardadas: el usuario las guarda a propósito.
/// Se entera del login/logout vía [updateAuth] (ver main.dart).
class RecipesProvider extends ChangeNotifier {
  String? _token;
  List<DrinkRecipe> _recent = [];
  List<DrinkRecipe> _saved = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<DrinkRecipe> get recent => _recent;
  List<DrinkRecipe> get saved => _saved;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _token != null;

  void updateAuth(String? token) {
    final wasLoggedIn = _token != null;
    _token = token;
    if (token == null && wasLoggedIn) {
      _recent = [];
      _saved = [];
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> fetchRecipes() async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiClient.get('/recipes', token: _token);
      List<DrinkRecipe> parse(dynamic raw) =>
          (raw as List? ?? []).whereType<Map<String, dynamic>>().map(DrinkRecipe.fromJson).toList();
      _recent = parse(data['recent']);
      _saved = parse(data['saved']);
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Última personalización usada con [productId] (null si no hay o
  /// no se pudo consultar: nunca bloquea el estudio).
  Future<DrinkRecipe?> lastFor(String productId) async {
    if (_token == null) return null;
    try {
      final data = await ApiClient.get('/recipes/last/$productId', token: _token);
      final raw = data['recipe'];
      return raw is Map<String, dynamic> ? DrinkRecipe.fromJson(raw) : null;
    } on ApiException {
      return null;
    }
  }

  Map<String, dynamic> _body(String productId, ProductCustomization c, double milkLevel) => {
        'productId': productId,
        'customization': {...c.toJson(), 'milkLevel': milkLevel},
      };

  /// Registra la receta como reciente (al agregar al carrito). Un error
  /// aquí nunca debe afectar al pedido.
  Future<void> recordRecent(String productId, ProductCustomization c, double milkLevel) async {
    if (_token == null) return;
    try {
      await ApiClient.post('/recipes', token: _token, body: _body(productId, c, milkLevel));
    } on ApiException {
      // Silencioso: es un registro de comodidad.
    }
  }

  /// Guarda la receta a propósito. Devuelve un mensaje de error o null.
  Future<String?> saveRecipe(String productId, ProductCustomization c, double milkLevel, {String? name}) async {
    if (_token == null) return 'Inicia sesión para guardar tus recetas';
    try {
      await ApiClient.post('/recipes', token: _token, body: {
        ..._body(productId, c, milkLevel),
        'saved': true,
        'name': ?name,
      });
      await fetchRecipes();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> setSaved(DrinkRecipe recipe, bool saved) async {
    try {
      await ApiClient.patch('/recipes/${recipe.id}', token: _token, body: {'saved': saved});
      await fetchRecipes();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> rename(DrinkRecipe recipe, String name) async {
    try {
      await ApiClient.patch('/recipes/${recipe.id}', token: _token, body: {'name': name});
      await fetchRecipes();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> delete(DrinkRecipe recipe) async {
    try {
      await ApiClient.delete('/recipes/${recipe.id}', token: _token);
      _recent = _recent.where((r) => r.id != recipe.id).toList();
      _saved = _saved.where((r) => r.id != recipe.id).toList();
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }
}
