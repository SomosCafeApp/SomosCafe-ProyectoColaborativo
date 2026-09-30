import 'package:flutter/material.dart';

import '../models/review_model.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';

// Debe coincidir con MIN/MAX_COMMENT_LENGTH del backend
// (controllers/reviewsController.js).
const int kReviewCommentMinLength = 1;
const int kReviewCommentMaxLength = 300;

/// Reseñas de un producto puntual: se carga bajo demanda cuando el
/// usuario abre el detalle de un producto (no es una lista global).
/// Sigue el mismo patrón que CartProvider/AddressProvider: se entera
/// del login/logout vía [updateAuth] para saber con qué token escribir
/// y cuál es "mi" reseña dentro de la lista.
class ReviewsProvider extends ChangeNotifier {
  String? _token;
  String? _userId;

  List<Review> _reviews = [];
  double _averageRating = 0;
  int _totalReviews = 0;

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<Review> get reviews => _reviews;
  double get averageRating => _averageRating;
  int get totalReviews => _totalReviews;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  /// La reseña que el usuario logueado ya dejó en este producto
  /// (null si no ha reseñado o no hay sesión).
  Review? get myReview {
    if (_userId == null) return null;
    for (final review in _reviews) {
      if (review.userId == _userId) return review;
    }
    return null;
  }

  /// Llamado por el ChangeNotifierProxyProvider cada vez que cambia
  /// la sesión (login, logout o restauración automática al abrir la app).
  void updateAuth(String? token, String? userId) {
    _token = token;
    _userId = userId;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchProductReviews(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await ApiClient.get('/reviews/product/$productId');
      final raw = data['reviews'] as List? ?? [];
      _reviews = raw.map((e) => Review.fromJson(e as Map<String, dynamic>)).toList();
      _averageRating = (data['averageRating'] as num?)?.toDouble() ?? 0;
      _totalReviews = (data['totalReviews'] as num?)?.toInt() ?? _reviews.length;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Valida la longitud del comentario; retorna null si es válido o
  /// el mensaje de error a mostrar si no lo es.
  String? _validateComment(String trimmed) {
    if (trimmed.isEmpty) return 'La reseña no puede estar vacía';
    if (trimmed.length > kReviewCommentMaxLength) {
      return 'La reseña debe tener máximo $kReviewCommentMaxLength caracteres (tiene ${trimmed.length})';
    }
    return null;
  }

  /// Crea una reseña nueva para [productId]. El backend exige que
  /// [comment] tenga máximo $kReviewCommentMaxLength caracteres; se
  /// valida aquí también para dar feedback inmediato sin esperar la
  /// respuesta del servidor.
  Future<bool> submitReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    if (_token == null) {
      _errorMessage = 'Debes iniciar sesión para dejar una reseña';
      notifyListeners();
      return false;
    }

    final trimmed = comment.trim();
    final validationError = _validateComment(trimmed);
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await ApiClient.post('/reviews', token: _token, body: {
        'productId': productId,
        'rating': rating,
        'comment': trimmed,
      });

      final newReview = Review.fromJson(data['review'] as Map<String, dynamic>);
      _reviews.insert(0, newReview);
      _recalculateLocalAverage();

      _isSubmitting = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  /// Edita la reseña que el usuario ya había dejado.
  Future<bool> updateMyReview({
    required String reviewId,
    required int rating,
    required String comment,
  }) async {
    if (_token == null) return false;

    final trimmed = comment.trim();
    final validationError = _validateComment(trimmed);
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await ApiClient.put('/reviews/$reviewId', token: _token, body: {
        'rating': rating,
        'comment': trimmed,
      });

      final updated = Review.fromJson(data['review'] as Map<String, dynamic>);
      final index = _reviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        _reviews[index] = updated;
      }
      _recalculateLocalAverage();

      _isSubmitting = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMyReview(String reviewId) async {
    if (_token == null) return false;

    final backup = List<Review>.from(_reviews);
    _reviews.removeWhere((r) => r.id == reviewId);
    _recalculateLocalAverage();
    notifyListeners();

    try {
      await ApiClient.delete('/reviews/$reviewId', token: _token);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _reviews = backup; // revertimos si falló
      _recalculateLocalAverage();
      notifyListeners();
      return false;
    }
  }

  /// Recalcula promedio/total localmente para reflejar el cambio de
  /// inmediato en la UI, sin esperar a un refetch completo.
  void _recalculateLocalAverage() {
    _totalReviews = _reviews.length;
    _averageRating = _totalReviews > 0
        ? _reviews.map((r) => r.rating).reduce((a, b) => a + b) / _totalReviews
        : 0;
  }

  /// Limpia el estado (útil al salir de la pantalla de detalle).
  void reset() {
    _reviews = [];
    _averageRating = 0;
    _totalReviews = 0;
    _errorMessage = null;
  }
}
