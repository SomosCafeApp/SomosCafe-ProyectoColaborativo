import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// --- FORMATEADORES PARA LOS INPUTS ---

// Formatea el número de tarjeta insertando un espacio cada 4 dígitos (máx. 16 dígitos)
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(' ', '');

    if (text.length > 16) {
      text = text.substring(0, 16);
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

// Formatea la fecha de vencimiento insertando '/' tras los primeros 2 dígitos (MM/YY)
class CardExpiryInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll('/', '');

    if (text.length > 4) {
      text = text.substring(0, 4);
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex == 2 && nonZeroIndex != text.length) {
        buffer.write('/');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

// --- MODELO DE DATOS ---

class PaymentCard {
  final String id;
  final String brand;
  final String lastFour;
  final String holderName;
  final String expiry;
  final bool isDefault;

  PaymentCard({
    required this.id,
    required this.brand,
    required this.lastFour,
    required this.holderName,
    required this.expiry,
    this.isDefault = false,
  });

  PaymentCard copyWith({
    String? id,
    String? brand,
    String? lastFour,
    String? holderName,
    String? expiry,
    bool? isDefault,
  }) {
    return PaymentCard(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      lastFour: lastFour ?? this.lastFour,
      holderName: holderName ?? this.holderName,
      expiry: expiry ?? this.expiry,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

// --- VISTA PRINCIPAL ---

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  final List<PaymentCard> _cards = [];

  void _showCardModal({PaymentCard? existingCard}) {
    final isEditing = existingCard != null;
    final cardNumberController = TextEditingController(
      text: isEditing ? '4532 0000 0000 ${existingCard.lastFour}' : '',
    );
    final holderNameController = TextEditingController(
      text: isEditing ? existingCard.holderName : '',
    );
    final expiryController = TextEditingController(
      text: isEditing ? existingCard.expiry : '',
    );
    final cvvController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;
        // Se usa la misma tonalidad del fondo principal (scaffoldBackgroundColor)
        final sheetBg = theme.scaffoldBackgroundColor;
        final textColor = isDark ? Colors.white : const Color(0xFF333333);
        final inputBg = isDark ? theme.cardColor : const Color(0xFFF9F6F0);
        final primaryColor = theme.colorScheme.primary;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: sheetBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'Editar Tarjeta' : 'Agregar Tarjeta',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: Icon(Icons.close, color: textColor.withOpacity(0.6)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInputLabel('Número de tarjeta', textColor),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: cardNumberController,
                    hint: '0000 0000 0000 0000',
                    icon: Icons.credit_card,
                    inputBg: inputBg,
                    textColor: textColor,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CardNumberInputFormatter(),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildInputLabel('Nombre en la tarjeta', textColor),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: holderNameController,
                    hint: 'NOMBRE APELLIDO',
                    icon: Icons.person_outline,
                    inputBg: inputBg,
                    textColor: textColor,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel('Vencimiento', textColor),
                            const SizedBox(height: 6),
                            _buildTextField(
                              controller: expiryController,
                              hint: 'MM/YY',
                              icon: Icons.calendar_today_outlined,
                              inputBg: inputBg,
                              textColor: textColor,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                CardExpiryInputFormatter(),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel('CVV', textColor),
                            const SizedBox(height: 6),
                            _buildTextField(
                              controller: cvvController,
                              hint: '123',
                              icon: Icons.lock_outline,
                              inputBg: inputBg,
                              textColor: textColor,
                              obscureText: true,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        final rawNum = cardNumberController.text.replaceAll(' ', '');
                        final last4 = rawNum.length >= 4
                            ? rawNum.substring(rawNum.length - 4)
                            : '4532';

                        setState(() {
                          if (isEditing) {
                            final index = _cards.indexWhere((c) => c.id == existingCard.id);
                            if (index != -1) {
                              _cards[index] = existingCard.copyWith(
                                holderName: holderNameController.text.isEmpty
                                    ? 'Juan Pérez'
                                    : holderNameController.text,
                                expiry: expiryController.text.isEmpty
                                    ? '09/27'
                                    : expiryController.text,
                                lastFour: last4,
                              );
                            }
                          } else {
                            final newCard = PaymentCard(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              brand: 'VISA',
                              lastFour: last4,
                              holderName: holderNameController.text.isEmpty
                                  ? 'Juan Pérez'
                                  : holderNameController.text,
                              expiry: expiryController.text.isEmpty
                                  ? '09/27'
                                  : expiryController.text,
                              isDefault: _cards.isEmpty,
                            );
                            _cards.add(newCard);
                          }
                        });
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        isEditing ? 'Guardar Cambios' : 'Guardar Tarjeta',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(PaymentCard card) {
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;
        final dialogBg = isDark ? theme.cardColor : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF333333);

        return Dialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3E1F23) : const Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: isDark ? const Color(0xFFFF6B6B) : Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '¿Eliminar tarjeta?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Esta acción no se puede deshacer.',
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: isDark ? Colors.white24 : const Color(0xFFE5DDD3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          setState(() {
                            _cards.removeWhere((c) => c.id == card.id);
                            if (card.isDefault && _cards.isNotEmpty) {
                              _cards[0] = _cards[0].copyWith(isDefault: true);
                            }
                          });
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'Eliminar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputLabel(String label, Color textColor) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color inputBg,
    required Color textColor,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: TextStyle(color: textColor, fontSize: 14),
        decoration: InputDecoration(
          counterText: '',
          hintText: hint,
          hintStyle: TextStyle(color: textColor.withOpacity(0.35), fontSize: 14),
          prefixIcon: Icon(icon, color: textColor.withOpacity(0.4), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryBrown = theme.colorScheme.primary;
    final bgCanvas = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = textColor.withOpacity(0.6);
    final outlinedBorderColor = isDark ? Colors.white24 : const Color(0xFFE5DDD3);
    final infoCardBg = isDark
        ? const Color(0xFF0E3A3F).withOpacity(0.5)
        : const Color(0xFFE0F7FA).withOpacity(0.5);
    final infoIconBg = isDark ? const Color(0xFF13565E) : const Color(0xFFB2EBF2);

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
                // Icono de retroceder circular translúcido
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
                      'Métodos de Pago',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${_cards.length} métodos guardados',
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
                    'Mis Métodos de Pago',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_cards.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'No tienes tarjetas guardadas',
                        style: TextStyle(color: subtitleColor, fontSize: 14),
                      ),
                    )
                  else
                    ..._cards.map((card) => _buildUserCardItem(card, cardColor, textColor, subtitleColor)),

                  const SizedBox(height: 12),

                  // Botón Agregar Tarjeta
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
                      onPressed: () => _showCardModal(),
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

                  Text(
                    'Otras Opciones de Pago',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildOtherOptionTile(
                    title: 'Nequi',
                    subtitle: 'Transferencia instantánea',
                    icon: Icons.account_balance_wallet_outlined,
                    iconBg: isDark ? const Color(0xFF3A1F2B) : const Color(0xFFFCE4EC),
                    iconColor: const Color(0xFFC2185B),
                    cardColor: cardColor,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    outlinedBorderColor: outlinedBorderColor,
                  ),
                  _buildOtherOptionTile(
                    title: 'PSE',
                    subtitle: 'Pago desde tu banco',
                    icon: Icons.account_balance_outlined,
                    iconBg: isDark ? const Color(0xFF17324A) : const Color(0xFFE1F5FE),
                    iconColor: const Color(0xFF0288D1),
                    cardColor: cardColor,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    outlinedBorderColor: outlinedBorderColor,
                  ),
                  _buildOtherOptionTile(
                    title: 'Efecty',
                    subtitle: 'Pago en puntos Efecty',
                    icon: Icons.location_on_outlined,
                    iconBg: isDark ? const Color(0xFF3D371C) : const Color(0xFFFFF8E1),
                    iconColor: const Color(0xFFF57F17),
                    cardColor: cardColor,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    outlinedBorderColor: outlinedBorderColor,
                  ),
                  _buildOtherOptionTile(
                    title: 'Efectivo',
                    subtitle: 'Pago contra entrega',
                    icon: Icons.attach_money_rounded,
                    iconBg: isDark ? const Color(0xFF1E3A22) : const Color(0xFFE8F5E9),
                    iconColor: const Color(0xFF2E7D32),
                    cardColor: cardColor,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    outlinedBorderColor: outlinedBorderColor,
                  ),
                  _buildOtherOptionTile(
                    title: 'Google Pay',
                    subtitle: 'Pago rápido con Google',
                    icon: Icons.phone_android_rounded,
                    iconBg: isDark ? const Color(0xFF23244A) : const Color(0xFFE8EAF6),
                    iconColor: const Color(0xFF3F51B5),
                    cardColor: cardColor,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    outlinedBorderColor: outlinedBorderColor,
                  ),

                  const SizedBox(height: 16),

                  // Card Pagos Seguros
                  Container(
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
                          child: const Icon(
                            Icons.credit_card,
                            color: Color(0xFF00838F),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pagos Seguros',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tus datos de pago están protegidos con encriptación de nivel bancario. Nunca almacenamos información sensible.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: subtitleColor,
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

  // Card para tarjetas guardadas
  Widget _buildUserCardItem(
    PaymentCard card,
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBadgeBg = isDark ? const Color(0xFF3D2E26) : const Color(0xFFF4EFEA);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3D2E1A) : const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.credit_card,
                  color: Color(0xFFFFA000),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          card.brand,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.blueAccent,
                          ),
                        ),
                        if (card.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: defaultBadgeBg,
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
                    const SizedBox(height: 2),
                    Text(
                      '${card.lastFour} **** **** ${card.lastFour}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '${card.holderName} - ${card.expiry}',
                      style: TextStyle(fontSize: 12, color: subtitleColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: isDark ? Colors.white10 : const Color(0xFFF5F5F5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => _showCardModal(existingCard: card),
                icon: Icon(Icons.edit_outlined, size: 18, color: textColor),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF3E1F23) : const Color(0xFFFFEBEE),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => _showDeleteDialog(card),
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: isDark ? const Color(0xFFFF6B6B) : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Tile genérico para otras opciones de pago
  Widget _buildOtherOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color cardColor,
    required Color textColor,
    required Color subtitleColor,
    required Color outlinedBorderColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: subtitleColor),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: textColor.withOpacity(0.4),
          ),
        ],
      ),
    );
  }
}