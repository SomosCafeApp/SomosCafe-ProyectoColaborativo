import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userLevel;

  const ProfileHeader({
    super.key,
    required this.userName,
    required this.userEmail,
    this.userLevel = 'Nivel Gold',
  });

  @override
  Widget build(BuildContext context) {
    const primaryBrown = Color(0xFFA2784F);
    const darkBrown = Color(0xFF634832);
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'J';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            darkBrown,
            primaryBrown.withAlpha(217),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: darkBrown.withAlpha(230),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withAlpha(77), width: 2),
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.email_outlined, color: Colors.white.withAlpha(204), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      userEmail,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withAlpha(230),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withAlpha(102)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.workspace_premium_outlined, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        userLevel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}