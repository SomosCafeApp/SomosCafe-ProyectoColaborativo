import 'package:flutter/material.dart';

import 'recovery_style.dart';

/// Header con degradado café, botón de volver, icono de restaurar con
/// candado, título y subtítulo (pantallas de recuperar contraseña).
class RecoveryHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const RecoveryHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: recoveryGradient),
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.fromLTRB(32, top + 36, 32, 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildIcon(),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: top + 8,
            child: _buildBackButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.maybePop(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.restart_alt_rounded, color: Colors.white, size: 40),
          Positioned(
            right: 6,
            bottom: 6,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.lock_outline, color: Colors.white, size: 9),
            ),
          ),
        ],
      ),
    );
  }
}
