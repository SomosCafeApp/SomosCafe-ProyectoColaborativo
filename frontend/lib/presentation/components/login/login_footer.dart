import 'package:flutter/material.dart';

class LoginFooter extends StatelessWidget {
  final Color primaryBrown;
  final VoidCallback? onRegisterTap;

  const LoginFooter({
    super.key,
    required this.primaryBrown,
    this.onRegisterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿No tienes una cuenta? ',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        GestureDetector(
          onTap: onRegisterTap,
          child: Text(
            'Regístrate aquí',
            style: TextStyle(
              color: primaryBrown,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}