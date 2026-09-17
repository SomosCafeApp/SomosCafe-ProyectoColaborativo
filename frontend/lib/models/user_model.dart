class AppUser {
  final String id;
  final String name;
  final String lastName;
  final String email;
  final String role;
  final String phone;
  final int points;
  final String profileImage;
  final bool isActive;
  final bool isEmailVerified;

  AppUser({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.role,
    required this.phone,
    required this.points,
    required this.profileImage,
    required this.isActive,
    required this.isEmailVerified,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'USER',
      phone: json['phone'] as String? ?? '',
      points: (json['points'] as num?)?.toInt() ?? 0,
      profileImage: json['profileImage'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'lastName': lastName,
        'email': email,
        'role': role,
        'phone': phone,
        'points': points,
        'profileImage': profileImage,
        'isActive': isActive,
        'isEmailVerified': isEmailVerified,
      };
}
