import 'package:flutter/material.dart';

class ReviewItemCard extends StatelessWidget {
  final String name;
  final String comment;
  final String date;
  final int stars;
  final Color cardBg;
  final Color textColor;
  final Color mutedColor;

  const ReviewItemCard({
    super.key,
    required this.name,
    required this.comment,
    required this.date,
    required this.stars,
    required this.cardBg,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar circular con la inicial
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF9E774E),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Nombre de usuario
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
              ),
              // Estrellas
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: index < stars ? const Color(0xFFFFC107) : mutedColor.withOpacity(0.4),
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Comentario
          Text(
            comment,
            style: TextStyle(
              fontSize: 13,
              color: textColor.withOpacity(0.9),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          // Fecha
          Text(
            date,
            style: TextStyle(
              fontSize: 11,
              color: mutedColor,
            ),
          ),
        ],
      ),
    );
  }
}