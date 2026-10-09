import 'package:flutter/material.dart';

import '../models/promotion.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';

/// Promo del día que se muestra en el home (GET /promotions/promo-of-the-day,
/// pública: no requiere sesión). Si no hay promo vigente, [promo] es null
/// y el home simplemente no dibuja la tarjeta de oferta.
class PromoOfTheDayProvider extends ChangeNotifier {
  PromoOfTheDay? _promo;
  bool _isLoading = false;

  PromoOfTheDay? get promo => _promo;
  bool get isLoading => _isLoading;

  Future<void> fetchPromo() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiClient.get('/promotions/promo-of-the-day');
      final raw = data['promotion'];
      _promo = raw is Map<String, dynamic> ? PromoOfTheDay.fromJson(raw) : null;
    } on ApiException {
      // Si falla la red conservamos lo último que se mostró: el home
      // no debe romperse por no poder cargar la oferta.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
