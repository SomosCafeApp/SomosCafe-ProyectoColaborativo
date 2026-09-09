import 'package:flutter/material.dart';

class DeliveryInfoSection extends StatelessWidget {
  final Color iconBg;
  final Color iconColor;
  final Color textColor;
  final Color mutedColor;
  final Color borderColor;

  const DeliveryInfoSection({
    super.key,
    required this.iconBg,
    required this.iconColor,
    required this.textColor,
    required this.mutedColor,
    required this.borderColor,
  });

  Widget _buildTile(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
            Text(subtitle, style: TextStyle(fontSize: 10, color: mutedColor)),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTile(Icons.access_time_rounded, 'Tiempo estimado', '20-30 minutos'),
        Divider(height: 16, color: borderColor),
        _buildTile(Icons.local_shipping_outlined, 'Envío gratuito', 'En compras superiores a \$20.000'),
        Divider(height: 16, color: borderColor),
        _buildTile(Icons.location_on_outlined, 'Recogida en tienda', 'Punto principal disponible'),
      ],
    );
  }
}