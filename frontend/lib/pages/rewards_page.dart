import 'package:flutter/material.dart';
import '../widgets/rewards/reward_card.dart';
import '../widgets/rewards/reward_header.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  static const activeBrown = Color(0xFFA2784F);
  static const darkBrown = Color(0xFF5D4037);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RewardHeader(points: 450, nextRewardPoints: 100, progress: 0.75),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(Icons.auto_awesome, 'Disponibles para Ti'),
                    const SizedBox(height: 12),
                    RewardCard(
                      icon: Icons.percent,
                      iconBg: Colors.green.shade50,
                      iconColor: Colors.green,
                      title: '30% de Descuento',
                      subtitle: 'En tu próxima compra',
                      points: 200,
                      expiry: '3 días',
                      onRedeem: () {},
                    ),
                    const SizedBox(height: 12),
                    RewardCard(
                      icon: Icons.card_giftcard,
                      iconBg: Colors.pink.shade50,
                      iconColor: Colors.pink,
                      title: '2x1 en Postres',
                      subtitle: 'Compra uno y lleva otro gratis',
                      points: 350,
                      expiry: '7 días',
                      onRedeem: () {},
                    ),
                    const SizedBox(height: 20),
                    _buildSectionHeader(Icons.bookmark_outline, 'Sigue Acumulando'),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: const ListTile(
                        leading: CircleAvatar(backgroundColor: Color(0xFFFFF8E1), child: Icon(Icons.local_cafe_outlined, color: activeBrown)),
                        title: Text('Café Gratis', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Cualquier café de tamaño medio\n⭐ 50 puntos más'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFFFFFDE7), borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(Icons.auto_awesome, 'Cómo Ganar Puntos', color: Colors.orange),
                          const SizedBox(height: 12),
                          _buildInstruction(Icons.local_cafe, '10 puntos', 'por cada compra'),
                          _buildInstruction(Icons.star_outline, '50 puntos', 'por cada reseña'),
                          _buildInstruction(Icons.card_giftcard, '100 puntos', 'por referir amigos'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, {Color color = activeBrown}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkBrown)),
      ],
    );
  }

  Widget _buildInstruction(IconData icon, String boldText, String normalText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          CircleAvatar(radius: 16, backgroundColor: Colors.orange.shade100, child: Icon(icon, size: 16, color: activeBrown)),
          const SizedBox(width: 12),
          Text(boldText, style: const TextStyle(fontWeight: FontWeight.bold, color: darkBrown)),
          Text(' $normalText', style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}