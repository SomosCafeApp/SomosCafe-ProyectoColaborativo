import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../pages/addresses_page.dart';

class AddressCardItem extends StatelessWidget {
  final AddressItem item;
  final VoidCallback onDelete;

  const AddressCardItem({
    super.key,
    required this.item,
    required this.onDelete,
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

    final buttonBgColor = isDark
        ? AppColors.darkSurfaceSubtle
        : AppColors.lightSurfaceSubtle;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 50 : 8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  color: isDark ? const Color(0xFF1E2B35) : const Color(0xFFE3F2FD),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(painter: MapGridPainter(isDark: isDark)),
                      ),
                      Center(
                        child: Icon(
                          Icons.location_on,
                          color: isDark ? const Color(0xFF64B5F6) : const Color(0xFF1976D2),
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
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
                    Icon(Icons.location_on_outlined, size: 16, color: subtitleColor),
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
                    style: TextStyle(fontSize: 12, color: subtitleColor),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.near_me_outlined,
                        label: 'Ir',
                        bgColor: buttonBgColor,
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
                        bgColor: buttonBgColor,
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
                        bgColor: isDark ? const Color(0xFF381C1C) : const Color(0xFFFFF5F5),
                        textColor: const Color(0xFFE53935),
                        borderColor: isDark ? const Color(0xFF5C2424) : const Color(0xFFFFCDD2),
                        onTap: onDelete,
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

class MapGridPainter extends CustomPainter {
  final bool isDark;

  MapGridPainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.blue.shade200 : Colors.blue).withAlpha(30)
      ..strokeWidth = 2.0;

    canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.7), paint);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.6, size.height), paint);
    canvas.drawLine(Offset(0, size.height * 0.8), Offset(size.width, size.height * 0.3), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}