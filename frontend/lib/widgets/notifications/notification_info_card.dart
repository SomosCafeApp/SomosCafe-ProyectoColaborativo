import 'package:flutter/material.dart';

class NotificationInfoCard extends StatelessWidget {
  final Color infoCardBg;
  final Color infoIconBg;
  final Color textColor;
  final Color subtitleColor;

  const NotificationInfoCard({
    super.key,
    required this.infoCardBg,
    required this.infoIconBg,
    required this.textColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: infoCardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: infoIconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications_none, color: Color(0xFF1976D2)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mantente Informado',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Activa las notificaciones push para enterarte al instante de tus pedidos, ofertas especiales y más.',
                  style: TextStyle(fontSize: 12, color: subtitleColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
