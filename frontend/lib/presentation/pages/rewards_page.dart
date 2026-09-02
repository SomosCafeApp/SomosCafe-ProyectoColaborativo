import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/theme_provider.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    const headerBgColor = Color(0xFFA2784F);
    final scaffoldBgColor = isDark ? const Color(0xFF1E1410) : const Color(0xFFFAF7F2);
    final cardBgColor = isDark ? const Color(0xFF2D211B) : Colors.white;
    final iconBgColor = isDark ? const Color(0xFF3D2E26) : const Color(0xFFF7F2EB);
    
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER CON PUNTOS
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: headerBgColor,
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
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
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
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Color(0xFFA2784F), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Disponibles para Ti',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _buildRewardCard(
                      cardBgColor: cardBgColor,
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                      icon: Icons.percent,
                      iconBg: isDark ? const Color(0xFF1E3A29) : Colors.green.shade50,
                      iconColor: isDark ? Colors.green.shade300 : Colors.green,
                      title: '30% de Descuento',
                      subtitle: 'En tu próxima compra',
                      points: 200,
                      expiry: '3 días',
                    ),
                    const SizedBox(height: 12),

                    _buildRewardCard(
                      cardBgColor: cardBgColor,
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                      icon: Icons.card_giftcard,
                      iconBg: isDark ? const Color(0xFF3D212A) : Colors.pink.shade50,
                      iconColor: isDark ? Colors.pinkAccent.shade100 : Colors.pink,
                      title: '2x1 en Postres',
                      subtitle: 'Compra uno y lleva otro gratis',
                      points: 350,
                      expiry: '7 días',
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        const Icon(Icons.bookmark_outline, color: Color(0xFFA2784F), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Sigue Acumulando',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Card(
                      elevation: 0,
                      color: cardBgColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: iconBgColor,
                          child: const Icon(Icons.local_cafe_outlined, color: Color(0xFFA2784F)),
                        ),
                        title: Text(
                          'Café Gratis',
                          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                        ),
                        subtitle: Text(
                          'Cualquier café de tamaño medio\n⭐ 50 puntos más',
                          style: TextStyle(color: subtitleColor),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // CAJA "CÓMO GANAR PUNTOS"
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? const Color(0xFF3D2E26) : const Color(0xFFEBE0D3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'Cómo Ganar Puntos',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildPointInstruction(
                            Icons.local_cafe_outlined,
                            '10 puntos',
                            'por cada compra',
                            iconBgColor,
                            textColor,
                            subtitleColor,
                          ),
                          _buildPointInstruction(
                            Icons.star_outline,
                            '50 puntos',
                            'por cada reseña',
                            iconBgColor,
                            textColor,
                            subtitleColor,
                          ),
                          _buildPointInstruction(
                            Icons.card_giftcard,
                            '100 puntos',
                            'por referir amigos',
                            iconBgColor,
                            textColor,
                            subtitleColor,
                          ),
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
    required Color cardBgColor,
    required Color textColor,
    required Color subtitleColor,
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
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: textColor,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(color: subtitleColor, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '⭐ $points puntos',
                      style: const TextStyle(
                        color: Color(0xFFA2784F),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '⏰ $expiry',
                  style: const TextStyle(color: Colors.orange, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA2784F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Canjear Ahora',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildPointInstruction(
    IconData icon,
    String boldText,
    String normalText,
    Color circleBg,
    Color textColor,
    Color subtitleColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: circleBg,
            child: Icon(icon, size: 16, color: Colors.amber),
          ),
          const SizedBox(width: 12),
          Text(
            boldText,
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ),
          Text(' $normalText', style: TextStyle(color: subtitleColor)),
        ],
      ),
    );
  }
}