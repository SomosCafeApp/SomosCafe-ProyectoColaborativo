import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'admin_add_button.dart';

/// Shell genérico de "lista + botón agregar + formulario" para el panel
/// admin (Promociones y Eventos). Cada pantalla solo aporta su propio
/// formulario ([formChild]) y cómo se ve cada tarjeta de la lista
/// ([itemBuilder]).
///
/// Igual que en Productos: al crear o editar ([showForm] == true) se
/// muestra SOLO el formulario; la lista y el botón "Agregar" vuelven al
/// cerrarlo.
class AdminCrudSection<T> extends StatelessWidget {
  final String addButtonLabel;
  final bool showForm;
  final VoidCallback onAddPressed;
  final Widget formChild;
  final bool isLoading;
  final List<T> items;
  final String emptyText;
  final Widget Function(BuildContext context, T item) itemBuilder;

  const AdminCrudSection({
    super.key,
    required this.addButtonLabel,
    required this.showForm,
    required this.onAddPressed,
    required this.formChild,
    required this.isLoading,
    required this.items,
    required this.emptyText,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleColor =
        theme.brightness == Brightness.dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    // Crear / editar: solo el formulario, sin la lista debajo.
    if (showForm) return formChild;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminAddButton(label: addButtonLabel, onPressed: onAddPressed),
        const SizedBox(height: 16),
        if (isLoading && items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(emptyText, style: TextStyle(color: subtitleColor, fontSize: 14)),
            ),
          )
        else
          ...items.map((item) => itemBuilder(context, item)),
      ],
    );
  }
}
