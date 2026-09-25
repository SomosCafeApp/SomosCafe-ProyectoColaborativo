import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/address_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/address/address_card_item.dart';
import '../widgets/address/address_form_card.dart';
import '../widgets/profile/profile_sub_page_header.dart';
import 'address_map_picker_page.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  bool _showForm = false;
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _recipientController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  double? _pickedLat;
  double? _pickedLng;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addresses = context.read<AddressProvider>();
      if (addresses.addresses.isEmpty) addresses.fetchAddresses();

      // Precargamos nombre/teléfono desde el perfil para no pedirlos dos veces.
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        _recipientController.text = '${user.name} ${user.lastName}'.trim();
        _phoneController.text = user.phone;
      }
    });
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<PickedLocation>(
      context,
      MaterialPageRoute(
        builder: (_) => AddressMapPickerPage(
          initialAddress: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          initialLat: _pickedLat,
          initialLng: _pickedLng,
        ),
      ),
    );

    if (result == null) return;

    setState(() {
      _addressController.text = result.address;
      _pickedLat = result.latitude;
      _pickedLng = result.longitude;
    });
  }

  Future<void> _saveAddress() async {
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final recipient = _recipientController.text.trim();
    final phone = _phoneController.text.trim();
    final city = _cityController.text.trim();

    if (name.isEmpty || address.isEmpty || recipient.isEmpty || phone.isEmpty || city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    final success = await context.read<AddressProvider>().createAddress(
          label: name,
          recipientName: recipient,
          phone: phone,
          address: address,
          city: city,
          latitude: _pickedLat,
          longitude: _pickedLng,
        );

    if (!mounted) return;

    if (success) {
      _nameController.clear();
      _addressController.clear();
      _cityController.clear();
      setState(() {
        _pickedLat = null;
        _pickedLng = null;
        _showForm = false;
      });
    } else {
      final error = context.read<AddressProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'No se pudo guardar la dirección')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _recipientController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryBrown = AppColors.primary;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = theme.brightness == Brightness.dark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final addressProvider = context.watch<AddressProvider>();
    final addresses = addressProvider.addresses;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          ProfileSubPageHeader(
            title: 'Direcciones',
            subtitle: '${addresses.length} ubicaciones guardadas',
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => addressProvider.fetchAddresses(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_showForm)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBrown,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          onPressed: () => setState(() => _showForm = true),
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'Agregar Nueva Dirección',
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    if (_showForm) ...[
                      AddressFormCard(
                        primaryBrown: primaryBrown,
                        nameController: _nameController,
                        addressController: _addressController,
                        recipientController: _recipientController,
                        phoneController: _phoneController,
                        cityController: _cityController,
                        hasLocation: _pickedLat != null,
                        onPickOnMap: _openMapPicker,
                        onClose: () => setState(() {
                          _showForm = false;
                          _pickedLat = null;
                          _pickedLng = null;
                        }),
                        onSave: _saveAddress,
                      ),
                      const SizedBox(height: 20),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      'Ubicaciones Guardadas',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 12),
                    if (addressProvider.isLoading && addresses.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (addresses.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'Aún no tienes direcciones guardadas',
                            style: TextStyle(color: subtitleColor, fontSize: 14),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: addresses.length,
                        itemBuilder: (context, index) => AddressCardItem(
                          item: addresses[index],
                          onDelete: () => context.read<AddressProvider>().deleteAddress(addresses[index].id),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
