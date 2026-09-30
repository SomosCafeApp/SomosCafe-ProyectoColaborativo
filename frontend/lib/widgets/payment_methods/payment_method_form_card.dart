import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Formulario inline para agregar una tarjeta, con el mismo estilo
/// visual (campos en píldora, sin bordes) que AddressFormCard.
class PaymentMethodFormCard extends StatelessWidget {
  final Color primaryBrown;
  final TextEditingController nameController;
  final TextEditingController last4Controller;
  final TextEditingController monthController;
  final TextEditingController yearController;
  final bool isSaving;
  final String? errorText;
  final VoidCallback onClose;
  final VoidCallback onSave;

  const PaymentMethodFormCard({
    super.key,
    required this.primaryBrown,
    required this.nameController,
    required this.last4Controller,
    required this.monthController,
    required this.yearController,
    required this.onClose,
    required this.onSave,
    this.isSaving = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = theme.cardTheme.color ?? (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final inputFillColor = isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;

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
                'Agregar Tarjeta',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
              ),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: inputFillColor, shape: BoxShape.circle),
                  child: Icon(Icons.close, size: 16, color: subtitleColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Nombre en la tarjeta',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textColor),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: 'Ej: Tarjeta principal',
              hintStyle: TextStyle(color: subtitleColor.withAlpha(180), fontSize: 14),
              filled: true,
              fillColor: inputFillColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Últimos 4 dígitos',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textColor),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: last4Controller,
            keyboardType: TextInputType.number,
            maxLength: 4,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: '4532',
              hintStyle: TextStyle(color: subtitleColor.withAlpha(180), fontSize: 14),
              filled: true,
              fillColor: inputFillColor,
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _LabeledField(
                  label: 'Mes (MM)',
                  controller: monthController,
                  hint: '08',
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  inputFillColor: inputFillColor,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LabeledField(
                  label: 'Año (AAAA)',
                  controller: yearController,
                  hint: '2028',
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  inputFillColor: inputFillColor,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          if (errorText != null) ...[
            const SizedBox(height: 12),
            Text(errorText!, style: const TextStyle(color: Color(0xFFE53935), fontSize: 12)),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: isDark ? Colors.white.withAlpha(30) : const Color(0xFFE5DDD3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: isSaving ? null : onClose,
                    child: Text('Cancelar', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: isSaving ? null : onSave,
                    child: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final Color textColor;
  final Color subtitleColor;
  final Color inputFillColor;
  final TextInputType? keyboardType;

  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.textColor,
    required this.subtitleColor,
    required this.inputFillColor,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textColor)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: subtitleColor.withAlpha(180), fontSize: 14),
            filled: true,
            fillColor: inputFillColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
