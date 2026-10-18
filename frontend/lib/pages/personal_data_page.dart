import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/app_date_picker.dart';
import '../providers/auth_provider.dart';
import '../widgets/profile/profile_sub_page_header.dart';
import '../widgets/settings/delete_account_sheet.dart';
import '../widgets/settings/settings_input_field.dart';
import '../widgets/settings/settings_primary_button.dart';

/// Configuración → Datos personales: nombre, apellido, teléfono y
/// cumpleaños. El correo no se puede cambiar (es el usuario de la
/// cuenta). El cumpleaños se registra una sola vez y da derecho al
/// cupón de cumpleaños.
class PersonalDataPage extends StatefulWidget {
  const PersonalDataPage({super.key});

  @override
  State<PersonalDataPage> createState() => _PersonalDataPageState();
}

class _PersonalDataPageState extends State<PersonalDataPage> {
  late final TextEditingController _name;
  late final TextEditingController _lastName;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  final _birthDisplay = TextEditingController();

  /// "AAAA-MM-DD" elegido (o el ya guardado).
  String? _birthDate;
  late final bool _birthLocked;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _name = TextEditingController(text: user?.name ?? '');
    _lastName = TextEditingController(text: user?.lastName ?? '');
    _phone = TextEditingController(text: user?.phone ?? '');
    _email = TextEditingController(text: user?.email ?? '');
    _birthDate = user?.birthDate;
    _birthLocked = user?.birthDate != null;
    _birthDisplay.text = _formatBirth(_birthDate);
  }

  @override
  void dispose() {
    for (final c in [_name, _lastName, _phone, _email, _birthDisplay]) {
      c.dispose();
    }
    super.dispose();
  }

  /// "1995-03-07" → "07/03/1995".
  String _formatBirth(String? iso) {
    if (iso == null || iso.length != 10) return '';
    return '${iso.substring(8, 10)}/${iso.substring(5, 7)}/${iso.substring(0, 4)}';
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showAppDatePicker(
      context,
      initialDate: DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Tu cumpleaños (solo se registra una vez)',
    );
    if (picked == null) return;

    final iso = '${picked.year.toString().padLeft(4, '0')}-'
        '${picked.month.toString().padLeft(2, '0')}-'
        '${picked.day.toString().padLeft(2, '0')}';
    setState(() {
      _birthDate = iso;
      _birthDisplay.text = _formatBirth(iso);
    });
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      _snack('Ingresa tu nombre');
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.updateProfile(
      name: _name.text,
      lastName: _lastName.text,
      phone: _phone.text,
      // Solo se envía si todavía no estaba registrado.
      birthDate: _birthLocked ? null : _birthDate,
    );
    if (!mounted) return;

    if (ok) {
      _snack('Datos actualizados');
      Navigator.pop(context);
    } else {
      _snack(auth.errorMessage ?? 'No se pudieron guardar los cambios');
    }
  }

  /// Elimina la cuenta: pide confirmación (y contraseña si la tiene) y, si
  /// sale bien, vuelve al inicio con la sesión cerrada.
  Future<void> _deleteAccount() async {
    final auth = context.read<AuthProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final password = await showDeleteAccountSheet(
      context,
      needsPassword: auth.user?.hasPassword ?? true,
    );
    if (password == null || !mounted) return;

    final ok = await auth.deleteAccount(password: password.isEmpty ? null : password);

    if (ok) {
      navigator.popUntil((route) => route.isFirst);
      messenger.showSnackBar(const SnackBar(content: Text('Tu cuenta fue eliminada')));
    } else {
      messenger.showSnackBar(SnackBar(content: Text(auth.errorMessage ?? 'No se pudo eliminar la cuenta')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          const ProfileSubPageHeader(
            title: 'Datos personales',
            subtitle: 'Actualiza tu información',
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SettingsInputField(
                    label: 'Nombre',
                    controller: _name,
                    icon: Icons.person_outline_rounded,
                    hint: 'Tu nombre',
                    maxLength: 50,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  SettingsInputField(
                    label: 'Apellido',
                    controller: _lastName,
                    icon: Icons.badge_outlined,
                    hint: 'Tu apellido',
                    maxLength: 50,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  SettingsInputField(
                    label: 'Teléfono',
                    controller: _phone,
                    icon: Icons.phone_outlined,
                    hint: '300 123 4567',
                    keyboardType: TextInputType.phone,
                    maxLength: 20,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+()\-\s]'))],
                  ),
                  const SizedBox(height: 16),
                  SettingsInputField(
                    label: 'Cumpleaños',
                    controller: _birthDisplay,
                    icon: Icons.cake_outlined,
                    hint: 'Elige tu fecha',
                    readOnly: true,
                    onTap: _birthLocked ? null : _pickBirthDate,
                    helper: _birthLocked
                        ? 'Ya está registrado y no se puede cambiar.'
                        : 'Solo se puede registrar una vez. Te regalamos un cupón cada año',
                  ),
                  const SizedBox(height: 16),
                  SettingsInputField(
                    label: 'Correo electrónico',
                    controller: _email,
                    icon: Icons.email_outlined,
                    readOnly: true,
                    helper: 'El correo no se puede cambiar.',
                  ),
                  const SizedBox(height: 28),
                  SettingsPrimaryButton(label: 'Guardar cambios', isLoading: isLoading, onPressed: _save),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Tus datos solo se usan para tus pedidos y recompensas.',
                      style: TextStyle(fontSize: 11, color: subtitleColor),
                    ),
                  ),
                  // Las cuentas de administrador no se pueden eliminar.
                  if (!context.read<AuthProvider>().isAdmin) ...[
                    const SizedBox(height: 28),
                    Divider(color: isDark ? Colors.white12 : Colors.black12),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: isLoading ? null : _deleteAccount,
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: const Text('Eliminar cuenta', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFE53935),
                          side: const BorderSide(color: Color(0xFFE53935)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
