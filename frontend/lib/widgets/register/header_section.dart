import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  final Color primaryColor;

  const HeaderSection({super.key, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 260,
          width: double.infinity,
          color: primaryColor,
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.local_cafe_outlined, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 16),
                const Text('Bienvenido', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 6),
                Text('Únete a nuestra comunidad de amantes del café', style: TextStyle(fontSize: 13, color: Colors.white.withAlpha(230))),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
        Positioned(
          top: 50,
          left: 20,
          child: CircleAvatar(
            backgroundColor: Colors.white.withAlpha(64),
            radius: 18,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
        ),
      ],
    );
  }
}