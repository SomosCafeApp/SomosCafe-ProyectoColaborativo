import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'settings_input_field.dart';

/// Hoja de confirmación para eliminar la cuenta. Devuelve la contraseña
/// escrita ('' si la cuenta no tiene, ej. Google) cuando el usuario
/// confirma, o null si cancela.
Future<String?> showDeleteAccountSheet(BuildContext context, {required bool needsPassword}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (_) => _DeleteAccountSheet(needsPassword: needsPassword),
  );
}

class _DeleteAccountSheet extends StatefulWidget {
  final bool needsPassword;

  const _DeleteAccountSheet({required this.needsPassword});

  @override
  State<_DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<_DeleteAccountSheet> {
  static const _danger = Color(0xFFE53935);

  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Reconstruye el botón al escribir para habilitarlo / deshabilitarlo.
    _password.addListener(() => setState(() {}));
    _confirmation.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  bool get _canDelete =>
      _confirmation.text.trim().toUpperCase() == 'ELIMINAR' &&
      (!widget.needsPassword || _password.text.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    Widget bullet(String text) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('•  ', style: TextStyle(color: subtitleColor)),
              Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: subtitleColor))),
            ],
          ),
        );

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: _danger.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: const Icon(Icons.delete_forever_rounded, color: _danger, size: 30),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(
                'Eliminar cuenta',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor),
              ),
            ),
            const SizedBox(height: 14),
            Text('Esta acción no se puede deshacer:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
            const SizedBox(height: 8),
            bullet('Perderás tus puntos, cupones, favoritos y direcciones.'),
            bullet('Tus pedidos anteriores se conservan, sin tus datos personales.'),
            bullet('Podrás volver a registrarte con el mismo correo cuando quieras.'),
            const SizedBox(height: 14),
            if (widget.needsPassword) ...[
              SettingsInputField(
                label: 'Tu contraseña',
                controller: _password,
                icon: Icons.lock_outline,
                hint: '••••••••',
                obscure: true,
              ),
              const SizedBox(height: 14),
            ],
            SettingsInputField(
              label: 'Escribe ELIMINAR para confirmar',
              controller: _confirmation,
              icon: Icons.edit_outlined,
              hint: 'ELIMINAR',
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _canDelete ? () => Navigator.pop(context, _password.text) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _danger,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                  disabledForegroundColor: subtitleColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Eliminar mi cuenta', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar', style: TextStyle(color: subtitleColor, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
