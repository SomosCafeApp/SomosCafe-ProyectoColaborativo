import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../models/promotion.dart';
import '../../providers/product_provider.dart';

/// Datos que devuelve el formulario ya validados.
class PromotionFormData {
  final String code;
  final String name;
  final String description;
  final PromotionDiscountType discountType;
  final double discountValue;
  final double? maximumDiscount;
  final List<String> productIds;
  final DateTime startDate;
  final DateTime endDate;

  const PromotionFormData({
    required this.code,
    required this.name,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.maximumDiscount,
    required this.productIds,
    required this.startDate,
    required this.endDate,
  });
}

/// Formulario inline para crear o editar una promoción (mismo patrón
/// que el formulario de direcciones). Si [initial] no es null, edita.
class PromotionFormCard extends StatefulWidget {
  final Promotion? initial;
  final bool isSubmitting;
  final VoidCallback onClose;
  final ValueChanged<PromotionFormData> onSubmit;

  const PromotionFormCard({
    super.key,
    this.initial,
    required this.isSubmitting,
    required this.onClose,
    required this.onSubmit,
  });

  @override
  State<PromotionFormCard> createState() => _PromotionFormCardState();
}

class _PromotionFormCardState extends State<PromotionFormCard> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _valueController;
  late final TextEditingController _maxController;

  late PromotionDiscountType _type;
  late Set<String> _productIds;
  DateTimeRange? _range;

  // Para mostrar nombres aunque el producto ya no esté en el catálogo
  // cargado (ej. se editó una promo vieja).
  late Map<String, String> _knownNames;

  String? _productsError;
  String? _datesError;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;

    _nameController = TextEditingController(text: p?.name ?? '');
    _codeController = TextEditingController(text: p?.code ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _valueController = TextEditingController(
      text: p == null ? '' : p.discountValue.toStringAsFixed(p.discountValue % 1 == 0 ? 0 : 1),
    );
    _maxController = TextEditingController(
      text: p?.maximumDiscount == null ? '' : p!.maximumDiscount!.toStringAsFixed(0),
    );

    _type = p?.discountType ?? PromotionDiscountType.percentage;
    _productIds = p == null ? <String>{} : p.products.map((e) => e.id).toSet();
    _knownNames = {for (final e in (p?.products ?? const <PromotionProduct>[])) e.id: e.name};
    _range = p == null ? null : DateTimeRange(start: p.startDate, end: p.endDate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  String _fmtDate(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
      initialDateRange: _range,
      helpText: 'Vigencia de la promoción',
      saveText: 'Listo',
    );
    if (picked != null) {
      setState(() {
        _range = picked;
        _datesError = null;
      });
    }
  }

  Future<void> _pickProducts() async {
    final products = context.read<ProductProvider>().products;

    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ProductPickerSheet(products: products, selected: _productIds),
    );

    if (result != null) {
      setState(() {
        _productIds = result;
        _productsError = null;
        for (final p in products) {
          _knownNames[p.id] = p.name;
        }
      });
    }
  }

  void _submit() {
    final formOk = _formKey.currentState!.validate();

    setState(() {
      _productsError = _productIds.isEmpty ? 'Asigna al menos un producto' : null;
      _datesError = _range == null ? 'Elige la vigencia' : null;
    });

    if (!formOk || _productIds.isEmpty || _range == null) return;

    final value = double.parse(_valueController.text.replaceAll(',', '.').trim());
    final maxText = _maxController.text.trim();

    // Vigencia: desde las 00:00 del primer día hasta las 23:59:59 del último.
    final start = DateTime(_range!.start.year, _range!.start.month, _range!.start.day);
    final end = DateTime(_range!.end.year, _range!.end.month, _range!.end.day, 23, 59, 59);

    widget.onSubmit(PromotionFormData(
      code: _codeController.text.trim().toUpperCase(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      discountType: _type,
      discountValue: value,
      maximumDiscount: _type == PromotionDiscountType.percentage && maxText.isNotEmpty
          ? double.parse(maxText)
          : null,
      productIds: _productIds.toList(),
      startDate: start,
      endDate: end,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = theme.cardTheme.color ?? (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final fill = isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;

    InputDecoration deco(String hint, {String? prefix, String? suffix}) => InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: subtitleColor.withAlpha(180), fontSize: 14),
          prefixText: prefix,
          suffixText: suffix,
          filled: true,
          fillColor: fill,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        );

    Widget label(String text) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textColor)),
        );

    Widget errorText(String? text) => text == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(left: 16, top: 6),
            child: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFFE53935))),
          );

    final selectedNames = _productIds.map((id) => _knownNames[id] ?? 'Producto').toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(isDark ? 50 : 10), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEditing ? 'Editar promoción' : 'Nueva promoción',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                ),
                GestureDetector(
                  onTap: widget.isSubmitting ? null : widget.onClose,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
                    child: Icon(Icons.close, size: 16, color: subtitleColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            label('Nombre'),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(color: textColor),
              decoration: deco('Ej: Lunes de capuchino'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa un nombre' : null,
            ),
            const SizedBox(height: 16),

            label('Código'),
            TextFormField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_-]')),
                LengthLimitingTextInputFormatter(20),
              ],
              style: TextStyle(color: textColor),
              decoration: deco('Ej: LUNES30 (único)'),
              validator: (v) {
                final value = (v ?? '').trim();
                if (value.length < 3) return 'Mínimo 3 caracteres (letras, números, - o _)';
                return null;
              },
            ),
            const SizedBox(height: 16),

            label('Descripción (opcional)'),
            TextFormField(
              controller: _descriptionController,
              maxLines: 2,
              maxLength: 140,
              style: TextStyle(color: textColor),
              decoration: deco('Se muestra en la tarjeta del home si es la promo del día'),
            ),
            const SizedBox(height: 8),

            label('Tipo de descuento'),
            Row(
              children: [
                for (final type in PromotionDiscountType.values) ...[
                  Expanded(
                    child: ChoiceChip(
                      label: SizedBox(width: double.infinity, child: Text(type.label, textAlign: TextAlign.center)),
                      selected: _type == type,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _type == type ? Colors.white : textColor,
                      ),
                      onSelected: (_) => setState(() => _type = type),
                    ),
                  ),
                  if (type == PromotionDiscountType.percentage) const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: 16),

            label(_type == PromotionDiscountType.percentage ? 'Porcentaje de descuento' : 'Valor del descuento'),
            TextFormField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
              style: TextStyle(color: textColor),
              decoration: _type == PromotionDiscountType.percentage
                  ? deco('Ej: 30', suffix: '%')
                  : deco('Ej: 2000', prefix: '\$ '),
              validator: (v) {
                final value = double.tryParse((v ?? '').replaceAll(',', '.').trim());
                if (value == null || value <= 0) return 'Ingresa un valor mayor a 0';
                if (_type == PromotionDiscountType.percentage && value > 100) return 'No puede superar 100%';
                return null;
              },
            ),

            if (_type == PromotionDiscountType.percentage) ...[
              const SizedBox(height: 16),
              label('Tope de descuento por unidad (opcional)'),
              TextFormField(
                controller: _maxController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(color: textColor),
                decoration: deco('Ej: 5000', prefix: '\$ '),
              ),
            ],
            const SizedBox(height: 16),

            label('Productos con descuento'),
            InkWell(
              onTap: _pickProducts,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(20)),
                child: _productIds.isEmpty
                    ? Row(
                        children: [
                          Icon(Icons.local_cafe_outlined, size: 18, color: subtitleColor),
                          const SizedBox(width: 8),
                          Text('Elegir productos', style: TextStyle(color: subtitleColor, fontSize: 14)),
                        ],
                      )
                    : Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final name in selectedNames)
                            Chip(
                              label: Text(name, style: const TextStyle(fontSize: 11)),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                        ],
                      ),
              ),
            ),
            errorText(_productsError),
            const SizedBox(height: 16),

            label('Vigencia'),
            InkWell(
              onTap: _pickDates,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(30)),
                child: Row(
                  children: [
                    Icon(Icons.date_range_outlined, size: 18, color: subtitleColor),
                    const SizedBox(width: 8),
                    Text(
                      _range == null ? 'Elegir fechas' : '${_fmtDate(_range!.start)}  →  ${_fmtDate(_range!.end)}',
                      style: TextStyle(color: _range == null ? subtitleColor : textColor, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            errorText(_datesError),
            const SizedBox(height: 20),

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
                        _isEditing ? 'Guardar cambios' : 'Crear promoción',
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

/// Hoja inferior para elegir los productos de la promoción
/// (búsqueda + casillas + "Seleccionar todos").
class _ProductPickerSheet extends StatefulWidget {
  final List<Product> products;
  final Set<String> selected;

  const _ProductPickerSheet({required this.products, required this.selected});

  @override
  State<_ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends State<_ProductPickerSheet> {
  late Set<String> _selected;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selected = {...widget.selected};
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visible = widget.products
        .where((p) => p.name.toLowerCase().contains(_query.trim().toLowerCase()))
        .toList();
    final allVisibleSelected = visible.isNotEmpty && visible.every((p) => _selected.contains(p.id));

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(hintText: 'Buscar producto', prefixIcon: Icon(Icons.search)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text('${_selected.length} seleccionados', style: theme.textTheme.bodySmall),
                    const Spacer(),
                    TextButton(
                      onPressed: visible.isEmpty
                          ? null
                          : () => setState(() {
                                if (allVisibleSelected) {
                                  _selected.removeAll(visible.map((p) => p.id));
                                } else {
                                  _selected.addAll(visible.map((p) => p.id));
                                }
                              }),
                      child: Text(allVisibleSelected ? 'Quitar todos' : 'Seleccionar todos'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: visible.isEmpty
                    ? const Center(child: Text('No hay productos'))
                    : ListView.builder(
                        itemCount: visible.length,
                        itemBuilder: (context, index) {
                          final p = visible[index];
                          final checked = _selected.contains(p.id);
                          return CheckboxListTile(
                            value: checked,
                            activeColor: AppColors.primary,
                            title: Text(p.name),
                            subtitle: Text(
                              '\$${p.price.toStringAsFixed(0)}${p.isAvailable ? '' : ' · No disponible'}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            onChanged: (v) => setState(() {
                              if (v == true) {
                                _selected.add(p.id);
                              } else {
                                _selected.remove(p.id);
                              }
                            }),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => Navigator.pop(context, _selected),
                    child: const Text('Listo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
