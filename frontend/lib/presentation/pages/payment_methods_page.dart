import 'package:flutter/material.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  // Estado para el método predeterminado ('card' o 'cash')
  String _defaultMethod = 'card';

  @override
  Widget build(BuildContext context) {
    const primaryBrown = Color(0xFF9E7247);
    const bgCanvas = Color(0xFFFAF7F2);

    return Scaffold(
      backgroundColor: bgCanvas,
      body: Column(
        children: [
          // --- HEADER SUPERIOR ---
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
            width: double.infinity,
            color: primaryBrown,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Métodos de Pago',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '2 métodos guardados',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- CONTENIDO SCROLLABLE ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECCIÓN: MIS MÉTODOS DE PAGO ---
                  const Text(
                    'Mis Métodos de Pago',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 1. Tarjeta de Crédito
                  _buildSavedMethodCard(
                    id: 'card',
                    title: 'Tarjeta de Crédito',
                    subtitle: '**** **** **** 4532',
                    icon: Icons.credit_card_rounded,
                    iconBg: const Color(0xFFFFF3E0),
                    iconColor: const Color(0xFFE65100),
                    isDefault: _defaultMethod == 'card',
                    onSetDefault: () {
                      setState(() {
                        _defaultMethod = 'card';
                      });
                    },
                  ),

                  // 2. Efectivo
                  _buildSavedMethodCard(
                    id: 'cash',
                    title: 'Efectivo',
                    subtitle: 'Pago contra entrega',
                    icon: Icons.attach_money_rounded,
                    iconBg: const Color(0xFFE8F5E9),
                    iconColor: const Color(0xFF2E7D32),
                    isDefault: _defaultMethod == 'cash',
                    onSetDefault: () {
                      setState(() {
                        _defaultMethod = 'cash';
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  // Botón "+ Agregar Tarjeta"
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBrown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Agregar Tarjeta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- SECCIÓN: OTRAS OPCIONES DE PAGO ---
                  const Text(
                    'Otras Opciones de Pago',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildOtherOptionTile(
                    title: 'Nequi',
                    subtitle: 'Transferencia instantánea',
                    icon: Icons.account_balance_wallet_outlined,
                    iconBg: const Color(0xFFFCE4EC),
                    iconColor: const Color(0xFFC2185B),
                  ),
                  _buildOtherOptionTile(
                    title: 'PSE',
                    subtitle: 'Pago desde tu banco',
                    icon: Icons.account_balance_outlined,
                    iconBg: const Color(0xFFE1F5FE),
                    iconColor: const Color(0xFF0288D1),
                  ),
                  _buildOtherOptionTile(
                    title: 'Efecty',
                    subtitle: 'Pago en puntos Efecty',
                    icon: Icons.location_on_outlined,
                    iconBg: const Color(0xFFFFF8E1),
                    iconColor: const Color(0xFFF57F17),
                  ),
                  _buildOtherOptionTile(
                    title: 'SuChance',
                    subtitle: 'Pago en puntos SuChance',
                    icon: Icons.location_on_outlined,
                    iconBg: const Color(0xFFF3E5F5),
                    iconColor: const Color(0xFF7B1FA2),
                  ),
                  _buildOtherOptionTile(
                    title: 'Apple Pay',
                    subtitle: 'Pago rápido con Apple',
                    icon: Icons.phone_iphone_rounded,
                    iconBg: const Color(0xFFECEFF1),
                    iconColor: const Color(0xFF37474F),
                  ),
                  _buildOtherOptionTile(
                    title: 'Google Pay',
                    subtitle: 'Pago rápido con Google',
                    icon: Icons.phone_android_rounded,
                    iconBg: const Color(0xFFE8EAF6),
                    iconColor: const Color(0xFF3F51B5),
                  ),

                  const SizedBox(height: 16),

                  // --- TARJETA DE PAGOS SEGUROS ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F7FA).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB2EBF2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.credit_card,
                            color: Color(0xFF00838F),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pagos Seguros',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Tus datos de pago están protegidos con encriptación de nivel bancario. Nunca almacenamos información sensible.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para tarjetas de "Mis Métodos de Pago"
  Widget _buildSavedMethodCard({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required bool isDefault,
    required VoidCallback onSetDefault,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        if (isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4EFEA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check, size: 12, color: Color(0xFF9E7247)),
                                SizedBox(width: 4),
                                Text(
                                  'Predeterminado',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF9E7247),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isDefault) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onSetDefault,
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFFAF7F2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Establecer como predeterminado',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Widget para opciones de "Otras Opciones de Pago"
  Widget _buildOtherOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE5DDD3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            onPressed: () {},
            icon: const Icon(Icons.add, size: 14, color: Colors.black87),
            label: const Text(
              'Agregar',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}