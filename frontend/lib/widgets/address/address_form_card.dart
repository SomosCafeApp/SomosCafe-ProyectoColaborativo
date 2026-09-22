import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AddressFormCard extends StatelessWidget {
  final Color primaryBrown;
  final TextEditingController nameController;
  final TextEditingController addressController;
  final bool hasLocation;
  final VoidCallback onClose;
  final VoidCallback onSave;
  final VoidCallback onPickOnMap;

  const AddressFormCard({
    super.key,
    required this.primaryBrown,
    required this.nameController,
    required this.addressController,
    required this.onClose,
    required this.onSave,
    required this.onPickOnMap,
    this.hasLocation = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = theme.cardTheme.color ??
        (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final inputFillColor = isDark
        ? AppColors.darkSurfaceSubtle
        : AppColors.lightSurfaceSubtle;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 50 : 10),
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
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: inputFillColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: subtitleColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
            controller: nameController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: 'Ej: Casa, Trabajo, Cafetería...',
              hintStyle: TextStyle(color: subtitleColor.withAlpha(180), fontSize: 14),
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
            controller: addressController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: subtitleColor),
              hintText: 'Ingresa la dirección o ubicación',
              hintStyle: TextStyle(color: subtitleColor.withAlpha(180), fontSize: 14),
              filled: true,
              fillColor: inputFillColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onPickOnMap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    hasLocation ? Icons.check_circle : Icons.map_outlined,
                    size: 16,
                    color: hasLocation ? Colors.green : primaryBrown,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    hasLocation ? 'Ubicación marcada en el mapa' : 'Elegir en el mapa',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: hasLocation ? Colors.green : primaryBrown,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: isDark ? Colors.white.withAlpha(30) : const Color(0xFFE5DDD3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: onClose,
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
                    onPressed: onSave,
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
}