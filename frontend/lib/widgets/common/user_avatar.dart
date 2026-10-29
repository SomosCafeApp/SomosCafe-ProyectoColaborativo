import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'avatar_art.dart';

/// Avatar de un usuario: su foto de perfil si tiene; si no (o si la
/// imagen no carga), sus iniciales. Se usa en reseñas, perfil y datos
/// personales para que se vea igual en toda la app.
class UserAvatar extends StatelessWidget {
  /// URL de la foto (vacía si el usuario no tiene).
  final String imageUrl;

  /// Texto que se muestra cuando no hay foto (ej. "JP").
  final String initials;

  /// Clave de un avatar predefinido (grano, taza, barista, latte,
  /// cafetera). Si viene, tiene prioridad sobre la foto y las iniciales.
  final String avatarPreset;

  final double size;

  /// Radio de las esquinas; null = círculo.
  final double? borderRadius;

  final Color backgroundColor;
  final Color textColor;
  final double? fontSize;
  final BoxBorder? border;

  const UserAvatar({
    super.key,
    required this.imageUrl,
    required this.initials,
    this.avatarPreset = '',
    this.size = 40,
    this.borderRadius,
    this.backgroundColor = AppColors.primary,
    this.textColor = Colors.white,
    this.fontSize,
    this.border,
  });

  /// Iniciales de nombre + apellido ("Juan Pérez" -> "JP"); "U" si no hay.
  static String initialsFor(String name, [String lastName = '']) {
    final first = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '';
    final last = lastName.trim().isNotEmpty ? lastName.trim()[0].toUpperCase() : '';
    final result = '$first$last';
    return result.isEmpty ? 'U' : result;
  }

  @override
  Widget build(BuildContext context) {
    final fallback = Center(
      child: Text(
        initials,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: fontSize ?? size * 0.38,
        ),
      ),
    );

    if (AvatarPresets.isValid(avatarPreset)) {
      final art = AvatarArt(presetKey: avatarPreset, size: size);
      if (border == null && borderRadius == null) return art;
      return Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? size / 2),
          border: border,
        ),
        child: art,
      );
    }

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius ?? size / 2),
        border: border,
      ),
      child: imageUrl.startsWith('http')
          ? Image.network(
              imageUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              // Mientras carga o si falla, se ven las iniciales.
              loadingBuilder: (_, child, progress) => progress == null ? child : fallback,
              errorBuilder: (_, _, _) => fallback,
            )
          : fallback,
    );
  }
}
