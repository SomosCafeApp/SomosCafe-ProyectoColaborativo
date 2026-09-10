import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/register_/custom_text_field.dart';
import '../components/register_/header_section.dart';
import '../state/auth_provider.dart';

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
  bool _obscurePass = true, _obscureConfirm = true;

  static const primaryColor = Color(0xFF9E754B);
  static const inputBgColor = Color(0xFFF7F4EF);

  @override
  void dispose() {
    for (var c in [_nameController, _emailController, _passController, _confirmPassController]) {
      c.dispose();
    }
    super.dispose();
  }

  void _handleRegister() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passController.text.trim();

    if (pass != _confirmPassController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Las contraseñas no coinciden')));
      return;
    }
    if (name.isNotEmpty && email.isNotEmpty && pass.length >= 6) {
      context.read<AuthProvider>().register(name, email, pass);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Datos inválidos (pass min 6 caracteres)')));
    }
  }

  Widget _buildEyeIcon(bool isObscured, VoidCallback onTap) => IconButton(
    icon: Icon(isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey.shade600, size: 20),
    onPressed: onTap,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const HeaderSection(primaryColor: primaryColor),
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 15, offset: const Offset(0, 8))]),
                      child: Column(
                        children: [
                          CustomTextField(label: 'Nombre completo', hintText: 'Juan Pérez', controller: _nameController, prefixIcon: Icons.person_outline),
                          const SizedBox(height: 16),
                          CustomTextField(label: 'Correo electrónico', hintText: 'tu@email.com', controller: _emailController, prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 16),
                          CustomTextField(label: 'Contraseña', hintText: '••••••••', controller: _passController, prefixIcon: Icons.lock_outline, obscureText: _obscurePass, suffixIcon: _buildEyeIcon(_obscurePass, () => setState(() => _obscurePass = !_obscurePass))),
                          const SizedBox(height: 16),
                          CustomTextField(label: 'Confirmar contraseña', hintText: '••••••••', controller: _confirmPassController, prefixIcon: Icons.lock_outline, obscureText: _obscureConfirm, suffixIcon: _buildEyeIcon(_obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm))),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _handleRegister,
                            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.person_add_outlined, color: Colors.white, size: 18), SizedBox(width: 8), Text('Crear cuenta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
                          ),
                          const SizedBox(height: 20),
                          Row(children: [Expanded(child: Divider(color: Colors.grey.shade300)), Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('O continúa con', style: TextStyle(fontSize: 12, color: Colors.grey.shade500))), Expanded(child: Divider(color: Colors.grey.shade300))]),
                          const SizedBox(height: 20),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(backgroundColor: inputBgColor, side: BorderSide(color: Colors.grey.shade300), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Google_Favicon_2025.svg/250px-Google_Favicon_2025.svg.png', height: 18, errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, color: Colors.red)), const SizedBox(width: 10), const Text('Google', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600))]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('¿Ya tienes una cuenta? ', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        GestureDetector(onTap: widget.onLoginTap, child: const Text('Inicia sesión aquí', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13))),
                      ],
                    ),
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