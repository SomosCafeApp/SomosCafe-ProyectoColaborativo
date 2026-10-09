import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_event.dart';
import '../../pages/event_detail_page.dart';
import '../../providers/active_event_provider.dart';
import 'event_popup.dart';

/// Envuelve la pantalla principal: al abrir la app consulta el evento
/// activo y, si hay uno, lo muestra como ventana emergente (una sola
/// vez por apertura). Si algo falla, la app sigue normal sin pop-up.
class EventPopupGate extends StatefulWidget {
  final Widget child;

  const EventPopupGate({super.key, required this.child});

  @override
  State<EventPopupGate> createState() => _EventPopupGateState();
}

class _EventPopupGateState extends State<EventPopupGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShow());
  }

  Future<void> _maybeShow() async {
    final provider = context.read<ActiveEventProvider>();
    if (provider.popupShown) return;
    provider.markPopupShown();

    final event = await provider.fetchActiveEvent();
    if (event == null || !mounted) return;

    // Precargamos la imagen para que el pop-up no aparezca vacío.
    if (event.hasImage) {
      try {
        await precacheImage(NetworkImage(event.image), context).timeout(const Duration(seconds: 6));
      } catch (_) {
        // Si no carga, el pop-up usa la tarjeta de texto.
      }
      if (!mounted) return;
    }

    _showDialog(event);
  }

  void _showDialog(AppEvent event) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withAlpha(170),
      builder: (dialogContext) => EventPopup(
        event: event,
        onClose: () => Navigator.of(dialogContext).pop(),
        onOpenDetails: () {
          Navigator.of(dialogContext).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => EventDetailPage(event: event)),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
