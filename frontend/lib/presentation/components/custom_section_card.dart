import 'package:flutter/material.dart';

class CustomSectionCard extends StatelessWidget {
  final Color cardColor;
  final Color textColor;
  final Color mutedColor;
  final String? title;
  final String? subtitle;
  final Widget child;

  const CustomSectionCard({
    super.key,
    required this.cardColor,
    required this.textColor,
    required this.mutedColor,
    this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                if (subtitle != null)
                  Text(subtitle!, style: TextStyle(fontSize: 10, color: mutedColor)),
              ],
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}