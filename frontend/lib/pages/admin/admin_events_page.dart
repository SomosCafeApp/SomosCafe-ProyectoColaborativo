import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_event.dart';
import '../../providers/active_event_provider.dart';
import '../../providers/admin_events_provider.dart';
import '../../widgets/admin/admin_crud_section.dart';
import '../../widgets/admin/confirm_action_dialog.dart';
import '../../widgets/admin/event/admin_event_card.dart';
import '../../widgets/admin/event/event_form_card.dart';
import '../../widgets/profile/profile_sub_page_header.dart';

/// Sección "Eventos" del panel admin: crear eventos con imagen
/// (Cloudinary), activar uno (sale como pop-up al abrir la app),
/// editar y eliminar.
class AdminEventsPage extends StatefulWidget {
  const AdminEventsPage({super.key});

  @override
  State<AdminEventsPage> createState() => _AdminEventsPageState();
}

class _AdminEventsPageState extends State<AdminEventsPage> {
  bool _showForm = false;
  AppEvent? _editing;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminEventsProvider>().fetchEvents();
    });
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _friendly(String? message) {
    final text = (message ?? '').toLowerCase();
    if (text.contains('already ended')) return 'Ese evento ya terminó, no se puede activar';
    if (text.contains('end date cannot be before')) return 'La fecha final no puede ser anterior a la inicial';
    if (text.contains('only jpg')) return 'Formato no permitido. Usa JPG, PNG, WEBP o AVIF';
    if (text.contains('file too large')) return 'La imagen supera los 5 MB';
    return message ?? 'Ocurrió un error inesperado';
  }

  void _openForm([AppEvent? event]) => setState(() {
        _editing = event;
        _showForm = true;
      });

  void _closeForm() => setState(() {
        _showForm = false;
        _editing = null;
      });

  Future<void> _handleSubmit(EventFormData data) async {
    final provider = context.read<AdminEventsProvider>();
    final editing = _editing;

    final ok = editing == null
        ? await provider.createEvent(
            name: data.name,
            description: data.description,
            location: data.location,
            startDate: data.startDate,
            endDate: data.endDate,
            isActive: data.isActive,
            image: data.image,
          )
        : await provider.updateEvent(
            editing.id,
            name: data.name,
            description: data.description,
            location: data.location,
            startDate: data.startDate,
            endDate: data.endDate,
            image: data.image,
          );

    if (!mounted) return;

    if (ok) {
      _closeForm();
      _snack(editing == null ? 'Evento creado' : 'Evento actualizado');
    } else {
      _snack(_friendly(provider.errorMessage));
    }
  }

  Future<void> _handleToggle(AppEvent event, bool value) async {
    final provider = context.read<AdminEventsProvider>();
    final ok = await provider.setActive(event.id, value);

    if (!mounted) return;

    if (ok) {
      // El pop-up del próximo arranque usará el nuevo evento activo.
      context.read<ActiveEventProvider>().fetchActiveEvent();
      _snack(value ? '"${event.name}" saldrá como pop-up al abrir la app' : 'Evento desactivado');
    } else {
      _snack(_friendly(provider.errorMessage));
    }
  }

  Future<void> _handleDelete(AppEvent event) async {
    final confirmed = await confirmAction(
      context,
      title: 'Eliminar evento',
      message: '¿Eliminar "${event.name}"? Esta acción no se puede deshacer.',
      confirmLabel: 'Sí, eliminar',
      destructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !mounted) return;

    final provider = context.read<AdminEventsProvider>();
    final ok = await provider.deleteEvent(event.id);

    if (!mounted) return;

    if (ok) {
      if (_editing?.id == event.id) _closeForm();
      _snack('Evento eliminado');
    } else {
      _snack(_friendly(provider.errorMessage));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminEventsProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const ProfileSubPageHeader(title: 'Eventos', subtitle: 'El evento activo sale al abrir la app'),
          Expanded(
            child: RefreshIndicator(
              onRefresh: provider.fetchEvents,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (provider.errorMessage != null && provider.events.isEmpty && !provider.isLoading)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)),
                      ),
                    AdminCrudSection<AppEvent>(
                      addButtonLabel: 'Agregar evento',
                      showForm: _showForm,
                      onAddPressed: _openForm,
                      formChild: EventFormCard(
                        key: ValueKey(_editing?.id ?? 'new'),
                        initial: _editing,
                        isSubmitting: provider.isSubmitting,
                        onClose: _closeForm,
                        onSubmit: _handleSubmit,
                      ),
                      isLoading: provider.isLoading,
                      items: provider.events,
                      emptyText: 'Todavía no hay eventos.',
                      itemBuilder: (context, event) => AdminEventCard(
                        event: event,
                        isBusy: provider.busyEventId == event.id,
                        onToggleActive: (value) => _handleToggle(event, value),
                        onEdit: () => _openForm(event),
                        onDelete: () => _handleDelete(event),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
