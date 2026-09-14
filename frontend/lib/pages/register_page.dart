import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/register/register_header.dart';
import '../widgets/register/register_form_card.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback? onLoginTap;
  const RegisterPage({super.key, this.onLoginTap});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passController.text.trim();
    final confirmPass = _confirmPassController.text.trim();
    if (pass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }
    if (name.isNotEmpty && email.isNotEmpty && pass.length >= 6) {
      context.read<AuthProvider>().register(name, email, pass);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos inválidos (contraseña mínimo 6 caracteres)'),
        ),
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
                    RegisterFormCard(
                      nameController: _nameController,
                      emailController: _emailController,
                      passwordController: _passController,
                      confirmPasswordController: _confirmPassController,
                      obscurePassword: _obscurePass,
                      obscureConfirmPassword: _obscureConfirm,
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
