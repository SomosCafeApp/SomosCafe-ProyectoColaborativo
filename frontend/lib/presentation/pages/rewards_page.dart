import 'package:flutter/material.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  static const activeBrown = Color(0xFFA2784F);
  static const darkBrown = Color(0xFF5D4037);
  static const lightBg = Color(0xFFFAF7F2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER CON PUNTOS
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF8C6E54),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Recompensas',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Gana puntos y obtén premios',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(38),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Tus Puntos', style: TextStyle(color: Colors.white70)),
                              Text('Próxima Recompensa', style: TextStyle(color: Colors.white70)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Row(
                                children: [
                                  Text(
                                    '450 ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(Icons.star, color: Colors.amber, size: 24),
                                ],
                              ),
                              Text(
                                '100',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: const LinearProgressIndicator(
                              value: 0.75,
                              backgroundColor: Colors.white24,
                              color: Colors.amber,
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // CONTENIDO DE CUPONES Y PUNTOS
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: activeBrown, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Disponibles para Ti',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: darkBrown,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _buildRewardCard(
                      icon: Icons.percent,
                      iconBg: Colors.green.shade50,
                      iconColor: Colors.green,
                      title: '30% de Descuento',
                      subtitle: 'En tu próxima compra',
                      points: 200,
                      expiry: '3 días',
                    ),
                    const SizedBox(height: 12),

                    _buildRewardCard(
                      icon: Icons.card_giftcard,
                      iconBg: Colors.pink.shade50,
                      iconColor: Colors.pink,
                      title: '2x1 en Postres',
                      subtitle: 'Compra uno y lleva otro gratis',
                      points: 350,
                      expiry: '7 días',
                    ),

                    const SizedBox(height: 20),

                    const Row(
                      children: [
                        Icon(Icons.bookmark_outline, color: activeBrown, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Sigue Acumulando',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: darkBrown,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: const ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(0xFFFFF8E1),
                          child: Icon(Icons.local_cafe_outlined, color: activeBrown),
                        ),
                        title: Text('Café Gratis', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Cualquier café de tamaño medio\n⭐ 50 puntos más'),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFDE7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.auto_awesome, color: Colors.orange, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Cómo Ganar Puntos',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: darkBrown,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildPointInstruction(Icons.local_cafe, '10 puntos', 'por cada compra'),
                          _buildPointInstruction(Icons.star_outline, '50 puntos', 'por cada reseña'),
                          _buildPointInstruction(Icons.card_giftcard, '100 puntos', 'por referir amigos'),
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

  static Widget _buildRewardCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required int points,
    required String expiry,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('⭐ $points puntos', style: const TextStyle(color: darkBrown, fontWeight: FontWeight.w600, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('⏰ $expiry', style: const TextStyle(color: Colors.orange, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: activeBrown,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Canjear Ahora', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildPointInstruction(IconData icon, String boldText, String normalText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.orange.shade100,
            child: Icon(icon, size: 16, color: activeBrown),
          ),
          const SizedBox(width: 12),
          Text(boldText, style: const TextStyle(fontWeight: FontWeight.bold, color: darkBrown)),
          Text(' $normalText', style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}