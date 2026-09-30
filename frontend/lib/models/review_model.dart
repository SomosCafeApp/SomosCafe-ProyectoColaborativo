/// Reseña de un producto (GET/POST /api/reviews).
class Review {
  final String id;
  final String userId;
  final String userName;
  final String userProfileImage;
  final String productId;
  final int rating;
  final String comment;
  final bool isVisible;
  final DateTime? createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userProfileImage,
    required this.productId,
    required this.rating,
    required this.comment,
    this.isVisible = true,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // userId puede venir como string (sin populate) o como
    // objeto {_id, name, lastName, profileImage} (con populate).
    String userId = '';
    String userName = 'Usuario';
    String userProfileImage = '';

    final rawUser = json['userId'];
    if (rawUser is Map<String, dynamic>) {
      userId = (rawUser['_id'] ?? '').toString();
      final name = rawUser['name'] as String? ?? '';
      final lastName = rawUser['lastName'] as String? ?? '';
      final fullName = [name, lastName].where((s) => s.isNotEmpty).join(' ');
      userName = fullName.isNotEmpty ? fullName : 'Usuario';
      userProfileImage = rawUser['profileImage'] as String? ?? '';
    } else if (rawUser != null) {
      userId = rawUser.toString();
    }

    // productId también puede venir como string u objeto populado.
    String productId = '';
    final rawProduct = json['productId'];
    if (rawProduct is Map<String, dynamic>) {
      productId = (rawProduct['_id'] ?? '').toString();
    } else if (rawProduct != null) {
      productId = rawProduct.toString();
    }

    DateTime? createdAt;
    final rawDate = json['createdAt'];
    if (rawDate is String) {
      createdAt = DateTime.tryParse(rawDate);
    }

    return Review(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      userId: userId,
      userName: userName,
      userProfileImage: userProfileImage,
      productId: productId,
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'] as String? ?? '',
      isVisible: json['isVisible'] as bool? ?? true,
      createdAt: createdAt,
    );
  }
}
