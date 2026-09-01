import 'package:flutter/material.dart';

class AddressItem {
  final String id;
  final String name;
  final String address;
  final String details;
  final String mapLabel;

  AddressItem({
    required this.id,
    required this.name,
    required this.address,
    required this.details,
    required this.mapLabel,
  });
}

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  bool _showForm = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final List<AddressItem> _addresses = [
    AddressItem(
      id: '1',
      name: 'Catación',
      address: 'Cra. 5 #8-12, Garzón, Huila, Colombia',
      details: 'Café de especialidad y cataciones',
      mapLabel: 'Catación',
    ),
    AddressItem(
      id: '2',
      name: 'Coffee Shop',
      address: 'Calle 7 #4-45, Garzón, Huila, Colombia',
      details: 'Punto de entrega principal',
      mapLabel: 'Coffee Shop',
    ),
  ];

  void _addAddress() {
    if (_nameController.text.trim().isEmpty || _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa los campos')),
      );
      return;
    }

    setState(() {
      _addresses.add(
        AddressItem(
          id: DateTime.now().toString(),
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          details: 'Ubicación personalizada',
          mapLabel: _nameController.text.trim(),
        ),
      );
      _nameController.clear();
      _addressController.clear();
      _showForm = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
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
    final mutedColor = textColor.withOpacity(0.4);
    final inputFillColor = isDark ? const Color(0xFF3D2E26) : const Color(0xFFF9F6F0);
    final hintColor = isDark ? Colors.white38 : Colors.black38;
    final closeBtnBg = isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF4F0EA);
    final actionBtnBg = isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFFAF7F2);
    final deleteBtnBg = isDark ? const Color(0xFF3A1F1F) : const Color(0xFFFFF5F5);
    final deleteBorderColor = isDark ? const Color(0xFF5C2E2E) : const Color(0xFFFFCDD2);
    final cancelBorderColor = isDark ? Colors.white24 : const Color(0xFFE5DDD3);
    final mapPillBg = isDark ? const Color(0xFF2D211B) : Colors.white;

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
                      'Direcciones',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${_addresses.length} ubicaciones guardadas',
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
                  // Botón principal Agregar Nueva Dirección
                  if (!_showForm)
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
                        onPressed: () => setState(() => _showForm = true),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Agregar Nueva Dirección',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Formulario de Agregar (Estilo 1)
                  if (_showForm) ...[
                    _buildFormCard(primaryBrown, cardColor, textColor, hintColor, inputFillColor, closeBtnBg, cancelBorderColor),
                    const SizedBox(height: 20),
                  ],

                  const SizedBox(height: 16),

                  // Título Sección Ubicaciones Guardadas
                  Text(
                    'Ubicaciones Guardadas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Lista de Ubicaciones con Mapa
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _addresses.length,
                    itemBuilder: (context, index) {
                      return _buildAddressCardWithMap(
                        _addresses[index],
                        cardColor,
                        textColor,
                        subtitleColor,
                        mutedColor,
                        mapPillBg,
                        actionBtnBg,
                        deleteBtnBg,
                        deleteBorderColor,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- FORMULARIO ---
  Widget _buildFormCard(Color primaryBrown, Color cardColor, Color textColor, Color hintColor, Color inputFillColor, Color closeBtnBg, Color cancelBorderColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Agregar Nueva Dirección',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _showForm = false),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: closeBtnBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Campo Nombre
          Text(
            'Nombre de la ubicación',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: 'Ej: Casa, Trabajo, Cafetería...',
              hintStyle: TextStyle(color: hintColor, fontSize: 14),
              filled: true,
              fillColor: inputFillColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Campo Buscar Dirección
          Text(
            'Buscar dirección',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _addressController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: hintColor),
              hintText: 'Ingresa la dirección o ubicación',
              hintStyle: TextStyle(color: hintColor, fontSize: 14),
              filled: true,
              fillColor: inputFillColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Botones Cancelar / Guardar
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: cancelBorderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => setState(() => _showForm = false),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBrown,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _addAddress,
                    child: const Text(
                      'Guardar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- TARJETA CON MAPA Y BOTONES ---
  Widget _buildAddressCardWithMap(
    AddressItem item,
    Color cardColor,
    Color textColor,
    Color subtitleColor,
    Color mutedColor,
    Color mapPillBg,
    Color actionBtnBg,
    Color deleteBtnBg,
    Color deleteBorderColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Previa del Mapa con Tag Superior (se mantiene con colores fijos: es una vista de mapa)
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  color: const Color(0xFFE3F2FD),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: MapGridPainter(),
                        ),
                      ),
                      const Center(
                        child: Icon(
                          Icons.location_on,
                          color: Color(0xFF1976D2),
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Pill de Categoría
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: mapPillBg,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_cafe_outlined, size: 14, color: textColor),
                      const SizedBox(width: 6),
                      Text(
                        item.mapLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Información de Dirección
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: mutedColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.address,
                        style: TextStyle(fontSize: 13, color: textColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    item.details,
                    style: TextStyle(fontSize: 12, color: mutedColor),
                  ),
                ),
                const SizedBox(height: 16),

                // Botones de Acción (Ir, Editar, Eliminar)
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.near_me_outlined,
                        label: 'Ir',
                        bgColor: actionBtnBg,
                        textColor: textColor,
                        borderColor: Colors.transparent,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.edit_outlined,
                        label: 'Editar',
                        bgColor: actionBtnBg,
                        textColor: textColor,
                        borderColor: Colors.transparent,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.delete_outline,
                        label: 'Eliminar',
                        bgColor: deleteBtnBg,
                        textColor: const Color(0xFFE53935),
                        borderColor: deleteBorderColor,
                        onTap: () {
                          setState(() {
                            _addresses.removeWhere((element) => element.id == item.id);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: textColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pintador mock para la cuadrícula del mapa estático
class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.12)
      ..strokeWidth = 2.0;

    canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.7), paint);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.6, size.height), paint);
    canvas.drawLine(Offset(0, size.height * 0.8), Offset(size.width, size.height * 0.3), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}