import 'package:flutter/material.dart';

class TermsSection {
  final int id;
  final String title;
  final String content;
  final IconData icon;
  final Color iconBgLight;
  final Color iconBgDark;
  final Color iconColor;

  TermsSection({
    required this.id,
    required this.title,
    required this.content,
    required this.icon,
    required this.iconBgLight,
    required this.iconBgDark,
    required this.iconColor,
  });
}

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryBrown = theme.colorScheme.primary;
    final bgCanvas = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = textColor.withOpacity(0.65);

    final cardBorder = isDark ? Colors.white12 : const Color(0xFFEFE8DF);

    final List<TermsSection> sections = [
      TermsSection(
        id: 1,
        title: 'Aceptación de los Términos',
        content:
            'Al usar esta aplicación aceptas estar vinculado por estos Términos y Condiciones. Si no estás de acuerdo con alguna de las condiciones aquí establecidas, no debes utilizar la aplicación. Nos reservamos el derecho de actualizar estos términos en cualquier momento.',
        icon: Icons.person_outline_rounded,
        iconBgLight: const Color(0xFFFFF3E0),
        iconBgDark: const Color(0xFF3D2E1A),
        iconColor: const Color(0xFFE65100),
      ),
      TermsSection(
        id: 2,
        title: 'Uso del Servicio',
        content:
            'Esta aplicación está destinada a facilitar la compra de productos en nuestra cafetería. Te comprometes a usar el servicio solo para fines legales y de acuerdo con estas condiciones. Queda prohibido el uso del servicio para actividades fraudulentas o que infrinjan derechos de terceros.',
        icon: Icons.inventory_2_outlined,
        iconBgLight: const Color(0xFFE1F5FE),
        iconBgDark: const Color(0xFF17324A),
        iconColor: const Color(0xFF0288D1),
      ),
      TermsSection(
        id: 3,
        title: 'Pagos y Precios',
        content:
            'Todos los precios están expresados en Pesos Colombianos (COP) e incluyen impuestos aplicables. El pago se procesa de forma segura. Nos reservamos el derecho de modificar los precios sin previo aviso. Los pedidos solo se confirman una vez verificado el pago exitoso.',
        icon: Icons.credit_card_outlined,
        iconBgLight: const Color(0xFFE8F5E9),
        iconBgDark: const Color(0xFF1E3A22),
        iconColor: const Color(0xFF2E7D32),
      ),
      TermsSection(
        id: 4,
        title: 'Privacidad y Datos',
        content:
            'Recopilamos y procesamos tus datos personales conforme a nuestra Política de Privacidad. Tu información se usa exclusivamente para gestionar pedidos, mejorar el servicio y enviarte comunicaciones si lo autorizas. Nunca vendemos tu información a terceros.',
        icon: Icons.shield_outlined,
        iconBgLight: const Color(0xFFF3E5F5),
        iconBgDark: const Color(0xFF35213D),
        iconColor: const Color(0xFF7B1FA2),
      ),
      TermsSection(
        id: 5,
        title: 'Pedidos y Cancelaciones',
        content:
            'Una vez confirmado un pedido, no garantizamos su cancelación. Si deseas cancelar, comunícate de inmediato con nuestro servicio de atención. Los reembolsos se procesan en un plazo de 3 a 5 días hábiles según el método de pago utilizado.',
        icon: Icons.error_outline_rounded,
        iconBgLight: const Color(0xFFFFF8E1),
        iconBgDark: const Color(0xFF3D371C),
        iconColor: const Color(0xFFF57F17),
      ),
      TermsSection(
        id: 6,
        title: 'Limitación de Responsabilidad',
        content:
            'La aplicación se provee "tal como está". No garantizamos que el servicio sea ininterrumpido o libre de errores. No seremos responsables por daños indirectos, incidentales o consecuentes derivados del uso de la aplicación o de la imposibilidad de usarla.',
        icon: Icons.description_outlined,
        iconBgLight: const Color(0xFFFFEBEE),
        iconBgDark: const Color(0xFF3E1F23),
        iconColor: const Color(0xFFC2185B),
      ),
    ];

    return Scaffold(
      backgroundColor: bgCanvas,
      body: Column(
        children: [
          // Header Superior
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
            width: double.infinity,
            color: primaryBrown,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Términos y Condiciones',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Lee nuestros términos',
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

          // Contenido Scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Última actualización: 1 de septiembre de 2026',
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Secciones legales
                  ...sections.map(
                    (sec) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark ? sec.iconBgDark : sec.iconBgLight,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  sec.icon,
                                  color: sec.iconColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${sec.id}. ${sec.title}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            sec.content,
                            style: TextStyle(
                              fontSize: 13,
                              color: subtitleColor,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Recuadro Informativo Legal de Cierre
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF281D17) : const Color(0xFFFAF5EE),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: cardBorder),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Para preguntas sobre estos términos, escríbenos a',
                          style: TextStyle(
                            fontSize: 12,
                            color: subtitleColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'somoscafeappgarzon@gmail.com',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '© 2026 Somos CafeApp · Garzón, Huila',
                          style: TextStyle(
                            fontSize: 11,
                            color: subtitleColor.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
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
}