import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../widgets/address/address_card_item.dart';
import '../widgets/address/address_form_card.dart';
import '../widgets/profile/profile_sub_page_header.dart';

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
  State createState() => _AddressesPageState();
}

class _AddressesPageState extends State {
  bool _showForm = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final List _addresses = [
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
    final theme = Theme.of(context);

    final primaryBrown = AppColors.primary;
    final textColor = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          ProfileSubPageHeader(
            title: 'Direcciones',
            subtitle: '${_addresses.length} ubicaciones guardadas',
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
                  Text('Ubicaciones Guardadas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 0),
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