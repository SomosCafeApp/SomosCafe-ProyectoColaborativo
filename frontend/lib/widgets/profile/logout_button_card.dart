import 'package:flutter/material.dart';

class LogoutButtonCard extends StatelessWidget {
  final VoidCallback onTap;

  const LogoutButtonCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent, // Fondo transparente
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE53935).withAlpha(100), // Borde sutil rojo
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Centra el icono y el texto
              children: const [
                Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFE53935),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE53935),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}