import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import 'reset_password_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final email = _emailController.text.trim();

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un correo válido'),
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();

    final success = await auth.requestPasswordRecovery(email);

    if (!mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordPage(email: email),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            auth.errorMessage ?? 'No se pudo enviar el código',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final auth = context.watch<AuthProvider>();

    final topBannerColor = AppColors.primary;

    final cardBgColor = isDark  ? AppColors.darkSurfaceSubtle  : AppColors.lightSurface;

    final inputBgColor = isDark  ? AppColors.darkBackground  : AppColors.lightSurfaceSubtle;

    final textColor = isDark  ? AppColors.darkTextPrimary  : AppColors.lightTextPrimary;

    final subtitleColor = isDark  ? AppColors.darkTextSecondary  : AppColors.lightTextSecondary;

    final buttonColor = AppColors.primary;

    final buttonTextColor = Colors.white;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 320,
              decoration: BoxDecoration(
                color: topBannerColor,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.restore,
                              color: Colors.white,
                              size: 38,
                            ),
                            Positioned(
                              right: 18,
                              bottom: 18,
                              child: Icon(
                                Icons.lock,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Recuperar Contraseña',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Ingresa tu correo registrado para recibir el código',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: 50,
              left: 20,
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.25),
                radius: 18,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 270,
                left: 24,
                right: 24,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Correo electrónico',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: subtitleColor,
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !auth.isLoading,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'tu@email.com',
                        hintStyle: TextStyle(
                          color: subtitleColor.withOpacity(0.5),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: subtitleColor,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: inputBgColor,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _handleSend,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          disabledBackgroundColor:
                              buttonColor.withOpacity(0.6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: auth.isLoading
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: buttonTextColor,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.send_outlined,
                                    size: 18,
                                    color: buttonTextColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Enviar Código',
                                    style: TextStyle(
                                      color: buttonTextColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                      ),
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