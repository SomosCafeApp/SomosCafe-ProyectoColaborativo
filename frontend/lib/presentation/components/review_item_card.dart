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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star_rounded,
                    size: 12,
                    color: index < stars ? Colors.amber : mutedColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(comment, style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.85))),
          const SizedBox(height: 4),
          Text(date, style: TextStyle(fontSize: 9, color: mutedColor)),
        ],
      ),
    );
  }
}