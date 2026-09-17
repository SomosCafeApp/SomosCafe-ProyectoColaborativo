import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  final String userName;
  final String userLastName;
  final String userEmail;


  const ProfileHeader({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userLastName,
  });

  @override
  Widget build(BuildContext context) {
    // Iniciales compuestas de Nombre + Apellido
    final firstInitial = userName.isNotEmpty ? userName[0].toUpperCase() : '';
    final lastInitial = userLastName.isNotEmpty ? userLastName[0].toUpperCase() : '';
    final initials = '$firstInitial$lastInitial'.isNotEmpty 
        ? '$firstInitial$lastInitial' 
        : 'U';

    // Nombre completo unificado
    final fullName = '$userName $userLastName'.trim();

    // Gradiente adaptado dinámicamente según el tema moca activo
    final gradientColors = [
      AppColors.primary,
      AppColors.primary.withAlpha(200),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 70, bottom: 30, left: 24, right: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
      ),
      child: Row(
        children: [
          // Avatar con las iniciales (Ej: "JD")
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(35),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withAlpha(80),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Información del Usuario
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Muestra Nombre + Apellido
                Text(
                  fullName.isNotEmpty ? fullName : 'Usuario',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      color: Colors.white.withAlpha(200),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        userEmail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withAlpha(230),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}