import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../core/constants/app_colors.dart';
import '../services/geocoding_service.dart';

/// Resultado que devuelve esta pantalla al hacer pop.
class PickedLocation {
  final String address;
  final double latitude;
  final double longitude;

  PickedLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

/// Deja al usuario fijar una ubicación de dos formas:
///   1) Escribiendo una dirección y buscándola (geocodifica y mueve
///      el mapa + el marcador ahí).
///   2) Tocando directamente sobre el mapa (mueve el marcador y
///      hace geocodificación inversa para mostrar la dirección
///      aproximada de ese punto).
class AddressMapPickerPage extends StatefulWidget {
  final String? initialAddress;
  final double? initialLat;
  final double? initialLng;

  const AddressMapPickerPage({
    super.key,
    this.initialAddress,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<AddressMapPickerPage> createState() => _AddressMapPickerPageState();
}

class _AddressMapPickerPageState extends State<AddressMapPickerPage> {
  // Bogotá como centro por defecto si no hay una dirección inicial.
  static const _defaultCenter = LatLng(4.7110, -74.0721);

  final _searchController = TextEditingController();
  GoogleMapController? _mapController;

  LatLng? _selectedPosition;
  String _selectedAddress = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialAddress ?? '';
    if (widget.initialLat != null && widget.initialLng != null) {
      _selectedPosition = LatLng(widget.initialLat!, widget.initialLng!);
      _selectedAddress = widget.initialAddress ?? '';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchAddress() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isSearching = true);

    try {
      final result = await GeocodingService.fromAddress(query);
      if (!mounted) return;

      final position = LatLng(result.latitude, result.longitude);
      setState(() {
        _selectedPosition = position;
        _selectedAddress = result.formattedAddress;
        _searchController.text = result.formattedAddress;
      });
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 16));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _handleMapTap(LatLng position) async {
    setState(() {
      _selectedPosition = position;
      _selectedAddress = '';
    });

    try {
      final result = await GeocodingService.fromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (!mounted) return;
      setState(() {
        _selectedAddress = result.formattedAddress;
        _searchController.text = result.formattedAddress;
      });
    } catch (_) {
      // La geocodificación inversa es "nice to have": si falla, el
      // usuario igual puede escribir la dirección manualmente.
    }
  }

  void _confirm() {
    if (_selectedPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Toca el mapa o busca una dirección primero')),
      );
      return;
    }

    Navigator.pop(
      context,
      PickedLocation(
        address: _selectedAddress.isNotEmpty
            ? _selectedAddress
            : _searchController.text.trim(),
        latitude: _selectedPosition!.latitude,
        longitude: _selectedPosition!.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedPosition ?? _defaultCenter,
              zoom: _selectedPosition != null ? 16 : 12,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onTap: _handleMapTap,
            markers: _selectedPosition == null
                ? {}
                : {
                    Marker(
                      markerId: const MarkerId('selected'),
                      position: _selectedPosition!,
                    ),
                  },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // Barra superior: volver + buscador de dirección.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: textColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: textColor, fontSize: 14),
                        onSubmitted: (_) => _searchAddress(),
                        decoration: InputDecoration(
                          hintText: 'Buscar dirección...',
                          hintStyle: TextStyle(color: subtitleColor, fontSize: 14),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: _isSearching
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : IconButton(
                                  icon: Icon(Icons.search, color: AppColors.primary),
                                  onPressed: _searchAddress,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Barra inferior: dirección detectada + confirmar.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: AppColors.primary, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _selectedAddress.isNotEmpty
                                ? _selectedAddress
                                : 'Toca el mapa para elegir un punto',
                            style: TextStyle(color: textColor, fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: _confirm,
                        child: const Text(
                          'Confirmar ubicación',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
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
