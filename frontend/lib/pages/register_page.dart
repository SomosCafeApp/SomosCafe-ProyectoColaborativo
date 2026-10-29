import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/avatar_choice.dart';
import '../providers/auth_provider.dart';
import '../widgets/common/user_avatar.dart';
import 'avatar_picker_page.dart';
import '../widgets/register/register_header.dart';
import '../widgets/register/register_form_card.dart';
import 'email_verification_page.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback? onLoginTap;
  const RegisterPage({super.key, this.onLoginTap});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  AvatarChoice? _avatar;

  Future<void> _chooseAvatar() async {
    final choice = await AvatarPickerPage.open(
      context,
      currentPreset: _avatar?.presetKey ?? '',
      initials: UserAvatar.initialsFor(_nameController.text, _lastNameController.text),
    );
    // Cancelar no cambia la selección anterior.
    if (choice != null && mounted) setState(() => _avatar = choice);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passController.text.trim();
    final confirmPass = _confirmPassController.text.trim();

    if (pass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    if (name.isEmpty || lastName.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa nombre, apellido y correo')),
      );
      return;
    }

    // El backend exige: min 6 caracteres, mayúscula, minúscula,
    // número y carácter especial. Lo validamos antes de enviar
    // para dar feedback inmediato.
    final passwordPolicy = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+\-=\[\]{};:\x27"\\|,.<>/?]).{6,}$',
    );
    if (!passwordPolicy.hasMatch(pass)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La contraseña debe tener mín. 6 caracteres, mayúscula, minúscula, número y carácter especial',
          ),
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      name: name,
      lastName: lastName,
      email: email,
      password: pass,
      avatarPreset: _avatar?.presetKey,
    );
    // Una foto de galería se sube tras el primer inicio de sesión.
    auth.setPendingAvatarImage(_avatar?.image);

    if (!mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EmailVerificationPage(
            email: email,
            onVerified: () {
              Navigator.pop(context); // vuelve al registro
              widget.onLoginTap?.call(); // y de ahí al login
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'No se pudo completar el registro')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subtitleColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeaderSection(onBackFallback: widget.onLoginTap),
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _AvatarSelector(
                      choice: _avatar,
                      initials: UserAvatar.initialsFor(_nameController.text, _lastNameController.text),
                      onTap: _chooseAvatar,
                    ),
                    const SizedBox(height: 12),
                    RegisterFormCard(
                      nameController: _nameController,
                      lastNameController: _lastNameController,
                      emailController: _emailController,
                      passwordController: _passController,
                      confirmPasswordController: _confirmPassController,
                      obscurePassword: _obscurePass,
                      obscureConfirmPassword: _obscureConfirm,
                      isLoading: auth.isLoading,
                      onTogglePassword: () {
                        setState(() {
                          _obscurePass = !_obscurePass;
                        });
                      },
                      onToggleConfirmPassword: () {
                        setState(() {
                          _obscureConfirm = !_obscureConfirm;
                        });
                      },
                      onRegister: _handleRegister,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Ya tienes una cuenta? ',
                          style: TextStyle(color: subtitleColor, fontSize: 13),
                        ),
                        GestureDetector(
                          onTap: widget.onLoginTap,
                          child: const Text(
                            'Inicia sesión aquí',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Avatar (opcional) en el registro: toca para elegir uno de los cinco
/// avatares o una foto de la galería.
class _AvatarSelector extends StatelessWidget {
  final AvatarChoice? choice;
  final String initials;
  final VoidCallback onTap;

  const _AvatarSelector({required this.choice, required this.initials, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final text = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final Widget avatar;
    if (choice?.image != null) {
      avatar = ClipOval(
        child: Image.memory(
          Uint8List.fromList(choice!.image!.bytes),
          width: 64,
          height: 64,
          fit: BoxFit.cover,
        ),
      );
    } else {
      avatar = UserAvatar(
        imageUrl: '',
        initials: initials,
        avatarPreset: choice?.presetKey ?? '',
        size: 64,
      );
    }

    return Semantics(
      button: true,
      label: 'Elegir avatar',
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              avatar,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(choice == null ? 'Elige tu avatar' : 'Tu avatar está listo',
                        style: TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(
                      choice == null ? 'Opcional · podrás cambiarlo cuando quieras' : 'Toca para cambiarlo',
                      style: TextStyle(color: sub, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
