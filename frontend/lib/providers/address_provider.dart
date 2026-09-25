import 'package:flutter/material.dart';

import '../models/address_model.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';

/// Direcciones del usuario, conectadas a /api/addresses.
/// Sigue el mismo patrón que CartProvider/FavoritesProvider: se
/// entera del login/logout vía [updateAuth] (ver main.dart).
class AddressProvider extends ChangeNotifier {
  List<AddressItem> _addresses = [];
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  List<AddressItem> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updateAuth(String? token) {
    final wasLoggedIn = _token != null;
    _token = token;

    if (token != null && !wasLoggedIn) {
      fetchAddresses();
    } else if (token == null && wasLoggedIn) {
      _addresses = [];
      notifyListeners();
    }
  }

  Future<void> fetchAddresses() async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiClient.get('/addresses', token: _token);
      final raw = data['addresses'] as List? ?? [];
      _addresses = raw
          .map((e) => AddressItem.fromJson(e as Map<String, dynamic>))
          .toList();
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAddress({
    required String label,
    required String recipientName,
    required String phone,
    required String address,
    required String city,
    String neighborhood = '',
    String additionalInfo = '',
    double? latitude,
    double? longitude,
  }) async {
    if (_token == null) return false;
    _errorMessage = null;

    try {
      final data = await ApiClient.post('/addresses', token: _token, body: {
        'label': label,
        'recipientName': recipientName,
        'phone': phone,
        'address': address,
        'city': city,
        'neighborhood': neighborhood,
        'additionalInfo': additionalInfo,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      });
      _addresses.insert(0, AddressItem.fromJson(data['address'] as Map<String, dynamic>));
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAddress(String id) async {
    if (_token == null) return false;

    final backup = List<AddressItem>.from(_addresses);
    _addresses.removeWhere((a) => a.id == id);
    notifyListeners();

    try {
      await ApiClient.delete('/addresses/$id', token: _token);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _addresses = backup; // revertimos si falló
      notifyListeners();
      return false;
    }
  }

  Future<bool> setDefaultAddress(String id) async {
    if (_token == null) return false;

    try {
      await ApiClient.patch('/addresses/$id/default', token: _token);
      await fetchAddresses();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }
}
