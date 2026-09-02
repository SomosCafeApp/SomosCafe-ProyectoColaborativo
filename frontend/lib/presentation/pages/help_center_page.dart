import 'package:flutter/material.dart';

class FaqItem {
  final int id;
  final String question;
  final String answer;

  FaqItem({
    required this.id,
    required this.question,
    required this.answer,
  });
}

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final List<FaqItem> _faqs = [
    FaqItem(
      id: 1,
      question: '¿Cómo realizo un pedido?',
      answer:
          'Navega al Menú, elige el producto que deseas, selecciona tamaño y extras si los hay, luego tócalo para añadirlo al carrito. Una vez listo, ve al Carrito y pulsa "Pagar" para completar tu pedido.',
    ),
    FaqItem(
      id: 2,
      question: '¿Puedo modificar o cancelar mi pedido?',
      answer:
          'Puedes modificar tu pedido siempre que no haya sido confirmado por la tienda. Una vez confirmado, comunícate con nosotros al número de atención para gestionarlo.',
    ),
    FaqItem(
      id: 3,
      question: '¿Cuánto tarda la entrega?',
      answer:
          'El tiempo estimado de entrega es entre 20 y 40 minutos dependiendo de tu ubicación dentro de Garzón, Huila. En horas pico puede tardar un poco más.',
    ),
    FaqItem(
      id: 4,
      question: '¿Cómo funciona el sistema de Recompensas?',
      answer:
          'Ganas puntos con cada compra. Por cada 1.000 COP en pedidos obtienes 1 punto. Al acumular 100 puntos puedes canjearlos por bebidas o descuentos especiales.',
    ),
    FaqItem(
      id: 5,
      question: '¿Qué métodos de pago aceptan?',
      answer:
          'Aceptamos tarjetas de crédito/débito Visa y Mastercard, transferencias por Nequi, PSE, pagos en efectivo contra entrega y puntos Efecty.',
    ),
    FaqItem(
      id: 6,
      question: '¿Dónde están ubicadas las cafeterías?',
      answer:
          'Contamos con 9 puntos en Garzón, Huila. Puedes ver todas las ubicaciones con mapas en la sección "Direcciones" de tu perfil.',
    ),
    FaqItem(
      id: 7,
      question: '¿Cómo cambio mi contraseña?',
      answer:
          'Ve a Configuración > Seguridad para cambiar tu contraseña. También puedes usar la opción "¿Olvidaste tu contraseña?" en la pantalla de inicio de sesión.',
    ),
  ];

  int? _expandedFaqId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryBrown = theme.colorScheme.primary;
    final bgCanvas = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = textColor.withOpacity(0.65);

    // Paleta de bordes y fondos para tarjetas y cajas desplegables
    final cardBorder = isDark ? Colors.white12 : const Color(0xFFEFE8DF);
    final numberCircleBg = isDark ? const Color(0xFF3D2E26) : const Color(0xFFF7F2EB);
    final answerBoxBg = isDark ? const Color(0xFF231A15) : const Color(0xFFFAF6F0);
    final answerBoxBorder = isDark ? Colors.white24 : const Color(0xFFEBE3D8);
    final dividerColor = isDark ? Colors.white12 : const Color(0xFFF0F0F0);

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
                      'Centro de Ayuda',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Preguntas frecuentes',
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
                    'Preguntas Frecuentes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Lista de Preguntas
                  ..._faqs.map((faq) {
                    final isExpanded = _expandedFaqId == faq.id;
                    return _buildFaqCard(
                      faq: faq,
                      isExpanded: isExpanded,
                      cardColor: cardColor,
                      cardBorder: cardBorder,
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                      numberCircleBg: numberCircleBg,
                      answerBoxBg: answerBoxBg,
                      answerBoxBorder: answerBoxBorder,
                      primaryBrown: primaryBrown,
                      onTap: () {
                        setState(() {
                          _expandedFaqId = isExpanded ? null : faq.id;
                        });
                      },
                    );
                  }),

                  const SizedBox(height: 20),

                  // Sección Contáctanos
                  Text(
                    'Contáctanos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tarjeta Contenedora de Opciones de Contacto con Borde
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: cardBorder),
                    ),
                    child: Column(
                      children: [
                        // Opción: Correo
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF3D2E1A) : const Color(0xFFFFF8E1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.email_outlined,
                                  color: Color(0xFFB8860B),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Correo de soporte',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'somoscafeappgarzon@gmail.com',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: subtitleColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        Divider(height: 1, color: dividerColor),

                        // Opción: Teléfono
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E3A22) : const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.phone_outlined,
                                  color: Color(0xFF2E7D32),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Teléfono',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '+57 311 234 5678 · Lun–Vie 8am–6pm',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: subtitleColor,
                                      ),
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

                  const SizedBox(height: 16),

                  // Botón Iniciar Chat
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
                      icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 18),
                      label: const Text(
                        'Iniciar Chat de Soporte',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildFaqCard({
    required FaqItem faq,
    required bool isExpanded,
    required Color cardColor,
    required Color cardBorder,
    required Color textColor,
    required Color subtitleColor,
    required Color numberCircleBg,
    required Color answerBoxBg,
    required Color answerBoxBorder,
    required Color primaryBrown,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: numberCircleBg,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${faq.id}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: primaryBrown,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      faq.question,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: subtitleColor,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: answerBoxBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: answerBoxBorder),
                ),
                child: Text(
                  faq.answer,
                  style: TextStyle(
                    fontSize: 13,
                    color: subtitleColor,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}