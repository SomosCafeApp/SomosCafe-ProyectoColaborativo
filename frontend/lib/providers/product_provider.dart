import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/api_exception.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

/// Maneja productos y categorías conectados al backend
/// (GET /api/products, GET /api/categories).
class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  bool _isLoadingCategories = false;
  String? _errorMessage;

  List<Product> get products => _products;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isLoadingCategories => _isLoadingCategories;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await ApiClient.get('/products');
      final rawList = data['products'] as List? ?? [];
      _products = rawList
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCategories() async {
    _isLoadingCategories = true;
    notifyListeners();

    try {
      final data = await ApiClient.get('/categories');
      final rawList = data['categories'] as List? ?? [];
      _categories = rawList
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      // Si falla, la home simplemente no muestra categorías dinámicas;
      // no es un error crítico para poder ver productos.
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  /// Carga productos y categorías juntos (usado por HomePage).
  Future<void> loadHomeData() async {
    await Future.wait([fetchProducts(), fetchCategories()]);
  }

  Future<Product?> fetchProductById(String id) async {
    try {
      final data = await ApiClient.get('/products/$id');
      return Product.fromJson(data['product'] as Map<String, dynamic>);
    } on ApiException {
      return null;
    }
  }
}
