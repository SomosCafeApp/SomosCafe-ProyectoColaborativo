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
  late final ActiveEventProvider _provider;
  int _handledRequests = 0;

  // Evita mostrar dos pop-ups a la vez (p. ej. el de apertura y el que
  // pide una push al abrir la app desde cerrada).
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _provider = context.read<ActiveEventProvider>();
    _handledRequests = _provider.popupRequestCount;
    _provider.addListener(_onProviderChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShow());
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderChanged);
    super.dispose();
  }

  /// El usuario tocó la push de un evento: se muestra el pop-up aunque
  /// ya se hubiera visto en esta apertura de la app.
  void _onProviderChanged() {
    if (_provider.popupRequestCount == _handledRequests) return;
    _handledRequests = _provider.popupRequestCount;
    _showActiveEvent();
  }

  Future<void> _maybeShow() async {
    if (_provider.popupShown) return;
    _provider.markPopupShown();
    await _showActiveEvent();
  }

  Future<void> _showActiveEvent() async {
    if (_busy) return;
    _busy = true;

    try {
      final event = await _provider.fetchActiveEvent();
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

      // Mientras el pop-up esté abierto sigue "ocupado".
      await _showDialog(event);
    } finally {
      _busy = false;
    }
  }

  Future<void> _showDialog(AppEvent event) {
    return showDialog<void>(
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
