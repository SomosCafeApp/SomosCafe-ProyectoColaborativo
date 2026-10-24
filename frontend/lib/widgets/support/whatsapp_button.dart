import 'package:flutter/material.dart';

import '../../services/support_service.dart';

/// Abre el WhatsApp de soporte con estado de carga y aviso de error.
Future<void> openSupportWhatsApp(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final error = await SupportService.openWhatsApp();
  if (error != null) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(error)));
  }
}

/// Botón verde "Escribir por WhatsApp".
class WhatsAppButton extends StatefulWidget {
  const WhatsAppButton({super.key, this.label = 'Escribir por WhatsApp'});
  final String label;

  @override
  State<WhatsAppButton> createState() => _WhatsAppButtonState();
}

class _WhatsAppButtonState extends State<WhatsAppButton> {
  bool _loading = false;

  Future<void> _open() async {
    setState(() => _loading = true);
    await openSupportWhatsApp(context);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: _loading ? null : _open,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF25D366),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: _loading
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Icon(Icons.chat_rounded, size: 18),
      label: Text(widget.label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
