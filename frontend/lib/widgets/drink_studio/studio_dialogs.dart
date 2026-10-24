import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Pide un nombre para guardar la receta, con el mismo estilo de los
/// diálogos de confirmación de la app. Devuelve el nombre (puede ir
/// vacío) o null si se cancela.
Future<String?> showRecipeNameDialog(BuildContext context, {String initial = ''}) {
  final controller = TextEditingController(text: initial);
  final dark = Theme.of(context).brightness == Brightness.dark;

  return showDialog<String>(
    context: context,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: theme.cardTheme.color,
        contentPadding: const EdgeInsets.all(24),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: dark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bookmark_added_rounded, color: AppColors.primary, size: 32),
              ),
              const SizedBox(height: 18),
              Text('Guardar receta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              const SizedBox(height: 8),
              Text(
                'Ponle un nombre para encontrarla fácil en tu perfil. Es opcional.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, height: 1.4, color: dark ? const Color(0xFFB0A49E) : const Color(0xFF757575)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 40,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Ej. Mi latte de la mañana',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: dark ? Colors.white24 : Colors.grey.shade300),
                        ),
                      ),
                      child: Text('Cancelar', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold)),
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
