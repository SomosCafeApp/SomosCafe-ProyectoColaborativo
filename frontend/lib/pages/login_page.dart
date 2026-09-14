import 'package:flutter/material.dart';
import '../widgets/login/login_header.dart';
import '../widgets/login/login_form_card.dart';
import '../widgets/login/login_footer.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const LoginHeader(),
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    LoginFormCard(
                      emailController: _emailController,
                      passwordController: _passwordController,
                    ),
                    const SizedBox(height: 20),
                    LoginFooter(
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