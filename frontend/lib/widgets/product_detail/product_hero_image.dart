import 'package:flutter/material.dart';

/// Imagen principal del producto. Antes esto era un carrusel que
/// nunca recibía la URL real de la imagen (por eso nunca se veía
/// nada); ahora muestra la imagen real del producto, con un
/// placeholder mientras carga o si no tiene imagen/falla la carga.
class ProductHeroImage extends StatelessWidget {
  final String imageUrl;
  final Color placeholderBg;
  final Color primaryColor;

  const ProductHeroImage({
    super.key,
    required this.imageUrl,
    required this.placeholderBg,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 280,
        width: double.infinity,
        color: placeholderBg,
        child: imageUrl.isEmpty
            ? _placeholderIcon()
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                      strokeWidth: 2,
                    ),
                  );
                },
                errorBuilder: (context, error, stack) => _placeholderIcon(),
              ),
      ),
    );
  }

  Widget _placeholderIcon() {
    return Center(
      child: Icon(Icons.coffee_rounded, size: 64, color: primaryColor),
    );
  }
}
