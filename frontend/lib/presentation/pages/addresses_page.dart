import 'package:flutter/material.dart';
import '../components/address/address_card_item.dart';
import '../components/address/address_form_card.dart';

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
      _addresses.add(AddressItem(
        id: DateTime.now().toString(),
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        details: 'Ubicación personalizada',
        mapLabel: _nameController.text.trim(),
      ));
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
    const primaryBrown = Color(0xFF9E7247);
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
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
                    const Text('Direcciones', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('${_addresses.length} ubicaciones guardadas', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.85))),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_showForm)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: primaryBrown, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                        onPressed: () => setState(() => _showForm = true),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Agregar Nueva Dirección', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  if (_showForm) ...[
                    AddressFormCard(
                      primaryBrown: primaryBrown,
                      nameController: _nameController,
                      addressController: _addressController,
                      onClose: () => setState(() => _showForm = false),
                      onSave: _addAddress,
                    ),
                    const SizedBox(height: 20),
                  ],
                  const SizedBox(height: 16),
                  const Text('Ubicaciones Guardadas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _addresses.length,
                    itemBuilder: (context, index) => AddressCardItem(
                      item: _addresses[index],
                      onDelete: () => setState(() => _addresses.removeAt(index)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}