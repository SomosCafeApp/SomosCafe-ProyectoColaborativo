import '../../../core/utils/app_date_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/app_event.dart';
import '../../../models/picked_image.dart';
import '../admin_form_style.dart';
import '../admin_image_picker.dart';

/// Datos validados que devuelve el formulario.
class EventFormData {
  final String name;
  final String description;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final PickedImage? image;

  const EventFormData({
    required this.name,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.image,
  });
}

/// Formulario inline para crear o editar un evento. Si [initial] no es
/// null, edita: la imagen actual se conserva salvo que se elija otra.
class EventFormCard extends StatefulWidget {
  final AppEvent? initial;
  final bool isSubmitting;
  final VoidCallback onClose;
  final ValueChanged<EventFormData> onSubmit;

  const EventFormCard({
    super.key,
    this.initial,
    required this.isSubmitting,
    required this.onClose,
    required this.onSubmit,
  });

  @override
  State<EventFormCard> createState() => _EventFormCardState();
}

class _EventFormCardState extends State<EventFormCard> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _location;

  DateTimeRange? _range;
  bool _activate = false;
  PickedImage? _image;
  String? _datesError;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final e = widget.initial;
    _name = TextEditingController(text: e?.name ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    _location = TextEditingController(text: e?.location ?? '');
    _range = e == null ? null : DateTimeRange(start: e.startDate, end: e.endDate);
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _location.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final picked = await showAppDateRangePicker(
      context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
      initialDateRange: _range,
      helpText: 'Fechas del evento',
    );
    if (picked != null) {
      setState(() {
        _range = picked;
        _datesError = null;
      });
    }
  }

  void _submit() {
    final formOk = _formKey.currentState!.validate();
    setState(() => _datesError = _range == null ? 'Elige las fechas del evento' : null);
    if (!formOk || _range == null) return;

    // Desde las 00:00 del primer día hasta las 23:59:59 del último.
    final start = DateTime(_range!.start.year, _range!.start.month, _range!.start.day);
    final end = DateTime(_range!.end.year, _range!.end.month, _range!.end.day, 23, 59, 59);

    widget.onSubmit(EventFormData(
      name: _name.text.trim(),
      description: _description.text.trim(),
      location: _location.text.trim(),
      startDate: start,
      endDate: end,
      isActive: _activate,
      image: _image,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final style = AdminFormStyle.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: style.cardDecoration,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminFormHeader(
              title: _isEditing ? 'Editar evento' : 'Nuevo evento',
              onClose: widget.isSubmitting ? null : widget.onClose,
            ),
            const SizedBox(height: 16),
            const AdminFieldLabel('Imagen del pop-up (opcional)'),
            AdminImagePicker(
              currentImageUrl: widget.initial?.image,
              picked: _image,
              onPicked: (img) => setState(() => _image = img),
              onCleared: () => setState(() => _image = null),
            ),
            const SizedBox(height: 16),
            const AdminFieldLabel('Nombre'),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(color: style.textColor),
              decoration: style.decoration('Ej: Noche de catas'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa un nombre' : null,
            ),
            const SizedBox(height: 16),
            const AdminFieldLabel('Descripción'),
            TextFormField(
              controller: _description,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(color: style.textColor),
              decoration: style.decoration('Cuenta de qué trata, horarios, precios…', radius: 20),
            ),
            const SizedBox(height: 16),
            const AdminFieldLabel('Lugar (opcional)'),
            TextFormField(
              controller: _location,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(color: style.textColor),
              decoration: style.decoration('Ej: Sede principal'),
            ),
            const SizedBox(height: 16),
            const AdminFieldLabel('Fechas'),
            InkWell(
              onTap: _pickDates,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(color: style.fill, borderRadius: BorderRadius.circular(30)),
                child: Row(
                  children: [
                    Icon(Icons.date_range_outlined, size: 18, color: style.subtitleColor),
                    const SizedBox(width: 8),
                    Text(
                      _range == null ? 'Elegir fechas' : '${_fmt(_range!.start)}  →  ${_fmt(_range!.end)}',
                      style: TextStyle(color: _range == null ? style.subtitleColor : style.textColor, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            if (_datesError != null)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 6),
                child: Text(_datesError!, style: const TextStyle(fontSize: 12, color: Color(0xFFE53935))),
              ),
            // Al editar, activar/desactivar se hace desde la tarjeta.
            if (!_isEditing) ...[
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.primary,
                title: Text('Activar ahora (pop-up al abrir la app)',
                    style: TextStyle(fontSize: 14, color: style.textColor)),
                subtitle: const Text('Desactiva el evento activo actual', style: TextStyle(fontSize: 11)),
                value: _activate,
                onChanged: (v) => setState(() => _activate = v),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: widget.isSubmitting ? null : _submit,
                child: widget.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        _isEditing ? 'Guardar cambios' : 'Crear evento',
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
