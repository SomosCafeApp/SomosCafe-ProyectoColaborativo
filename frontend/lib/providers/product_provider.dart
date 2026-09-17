import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/api_exception.dart';
import '../models/product_model.dart';

/// Maneja la lista de productos conectada al backend (GET /api/products).
class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
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

  Future<Product?> fetchProductById(String id) async {
    try {
      final data = await ApiClient.get('/products/$id');
      return Product.fromJson(data['product'] as Map<String, dynamic>);
    } on ApiException {
      return null;
    }
  }
}
