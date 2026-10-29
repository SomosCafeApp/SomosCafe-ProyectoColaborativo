class AppUser {
  final String id;
  final String name;
  final String lastName;
  final String email;
  final String role;
  final String phone;
  final int points;
  final String profileImage;

  /// 'none' | 'preset' | 'photo' y la clave del avatar predefinido
  /// (grano, taza, barista, latte, cafetera). Ver backend utils/avatars.js.
  final String avatarType;
  final String avatarPreset;
  final bool isActive;
  final bool isEmailVerified;

  /// Cumpleaños "AAAA-MM-DD" (null si aún no lo registra). Se puede
  /// registrar una sola vez; da derecho al cupón de cumpleaños.
  final String? birthDate;

  /// false en cuentas creadas con Google (no tienen contraseña).
  final bool hasPassword;

  AppUser({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.role,
    required this.phone,
    required this.points,
    required this.profileImage,
    this.avatarType = 'none',
    this.avatarPreset = '',
    required this.isActive,
    required this.isEmailVerified,
    this.birthDate,
    this.hasPassword = true,
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
      avatarType: _resolveAvatarType(json),
      avatarPreset: json['avatarPreset'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      birthDate: json['birthDate'] as String?,
      hasPassword: json['hasPassword'] as bool? ?? true,
    );
  }

  /// Misma regla que el backend: sesiones guardadas antes de existir los
  /// avatares no traen avatarType; si tienen foto, es una foto.
  static String _resolveAvatarType(Map<String, dynamic> json) {
    final type = json['avatarType'] as String? ?? '';
    if (type == 'preset' && (json['avatarPreset'] as String? ?? '').isNotEmpty) return 'preset';
    if (type == 'photo' && (json['profileImage'] as String? ?? '').isNotEmpty) return 'photo';
    if (type == 'none') return 'none';
    return (json['profileImage'] as String? ?? '').isNotEmpty ? 'photo' : 'none';
  }

  bool get hasPresetAvatar => avatarType == 'preset' && avatarPreset.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'lastName': lastName,
        'email': email,
        'role': role,
        'phone': phone,
        'points': points,
        'profileImage': profileImage,
        'avatarType': avatarType,
        'avatarPreset': avatarPreset,
        'isActive': isActive,
        'isEmailVerified': isEmailVerified,
        'birthDate': birthDate,
        'hasPassword': hasPassword,
      };
}
