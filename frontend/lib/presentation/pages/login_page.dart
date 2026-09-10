import 'package:flutter/material.dart';
import '../components/login/login_header.dart';
import '../components/login/login_form_card.dart';
import '../components/login/login_footer.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback? onRegisterTap;

  const LoginPage({
    super.key,
    this.onRegisterTap,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  static const primaryBrown = Color(0xFF9E754B);
  static const backgroundColor = Color(0xFFFAF7F2);
  static const inputBgColor = Color(0xFFF7F4EF);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const LoginHeader(primaryBrown: primaryBrown),
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    LoginFormCard(
                      primaryBrown: primaryBrown,
                      inputBgColor: inputBgColor,
                      emailController: _emailController,
                      passwordController: _passwordController,
                    ),
                    const SizedBox(height: 20),
                    LoginFooter(
                      primaryBrown: primaryBrown,
                      onRegisterTap: widget.onRegisterTap,
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