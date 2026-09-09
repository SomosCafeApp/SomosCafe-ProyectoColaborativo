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
                  'Configura cómo quieres recibir actualizaciones sobre tus pedidos, ofertas especiales y más.',
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

class NotificationScheduleCard extends StatelessWidget {
  final String startTime;
  final String endTime;
  final VoidCallback onSelectStartTime;
  final VoidCallback onSelectEndTime;
  final Color cardColor;
  final Color textColor;
  final Color subtitleColor;
  final Color borderColor;

  const NotificationScheduleCard({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.onSelectStartTime,
    required this.onSelectEndTime,
    required this.cardColor,
    required this.textColor,
    required this.subtitleColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Horario de Notificaciones',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Recibe notificaciones solo en este horario',
            style: TextStyle(fontSize: 12, color: subtitleColor),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimePickerBox(
                  label: 'Desde',
                  timeText: startTime,
                  onTap: onSelectStartTime,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimePickerBox(
                  label: 'Hasta',
                  timeText: endTime,
                  onTap: onSelectEndTime,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerBox({
    required String label,
    required String timeText,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: subtitleColor),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timeText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                Icon(
                  Icons.access_time_rounded,
                  size: 18,
                  color: textColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}