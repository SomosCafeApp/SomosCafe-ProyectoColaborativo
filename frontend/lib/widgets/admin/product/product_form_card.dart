import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/product_model.dart';
import '../../../models/picked_image.dart';
import '../../../providers/product_provider.dart';
import '../admin_form_style.dart';
import '../admin_image_picker.dart';

/// Datos validados que devuelve el formulario.
class ProductFormData {
  final String name;
  final String description;
  final double price;
  final String ingredients;
  final String? categoryId;
  final bool isAvailable;
  final PickedImage? image;

  const ProductFormData({
    required this.name,
    required this.description,
    required this.price,
    required this.ingredients,
    required this.categoryId,
    required this.isAvailable,
    required this.image,
  });
}

/// Formulario inline para crear o editar un producto. Si [initial] no
/// es null, edita: la imagen actual se conserva salvo que se elija otra.
class ProductFormCard extends StatefulWidget {
  final Product? initial;
  final bool isSubmitting;
  final VoidCallback onClose;
  final ValueChanged<ProductFormData> onSubmit;

  const ProductFormCard({
    super.key,
    this.initial,
    required this.isSubmitting,
    required this.onClose,
    required this.onSubmit,
  });

  @override
  State<ProductFormCard> createState() => _ProductFormCardState();
}

class _ProductFormCardState extends State<ProductFormCard> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _ingredients;

  String? _categoryId;
  bool _isAvailable = true;
  PickedImage? _image;
  String? _imageError;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _name = TextEditingController(text: p?.name ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _price = TextEditingController(text: p == null ? '' : p.price.toStringAsFixed(0));
    _ingredients = TextEditingController(text: p?.ingredientsText ?? '');
    _categoryId = p?.categoryId;
    _isAvailable = p?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _ingredients.dispose();
    super.dispose();
  }

  void _submit() {
    final formOk = _formKey.currentState!.validate();

    // Al crear la imagen es obligatoria; al editar solo si quiere cambiarla.
    final missingImage = !_isEditing && _image == null;
    setState(() => _imageError = missingImage ? 'Elige una imagen del producto' : null);

    if (!formOk || missingImage) return;

    widget.onSubmit(ProductFormData(
      name: _name.text.trim(),
      description: _description.text.trim(),
      price: double.parse(_price.text.trim()),
      ingredients: _ingredients.text.trim(),
      categoryId: _categoryId,
      isAvailable: _isAvailable,
      image: _image,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final style = AdminFormStyle.of(context);
    final categories = context.watch<ProductProvider>().categories;

    // Si la categoría del producto ya no existe en la lista, no se
    // ofrece como valor (evita un error del Dropdown).
    final validCategory = categories.any((c) => c.id == _categoryId) ? _categoryId : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: style.cardDecoration,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminFormHeader(
              title: _isEditing ? 'Editar producto' : 'Nuevo producto',
              onClose: widget.isSubmitting ? null : widget.onClose,
            ),
            const SizedBox(height: 16),
            AdminImagePicker(
              currentImageUrl: widget.initial?.imageUrl,
              picked: _image,
              errorText: _imageError,
              onPicked: (img) => setState(() {
                _image = img;
                _imageError = null;
              }),
            ),
            const SizedBox(height: 16),
            const AdminFieldLabel('Nombre'),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(color: style.textColor),
              decoration: style.decoration('Ej: Latte de vainilla'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa un nombre' : null,
            ),
            const SizedBox(height: 16),
            const AdminFieldLabel('Descripción'),
            TextFormField(
              controller: _description,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(color: style.textColor),
              decoration: style.decoration('Cuéntale al cliente de qué se trata', radius: 20),
            ),
            const SizedBox(height: 16),
            const AdminFieldLabel('Precio (COP)'),
            TextFormField(
              controller: _price,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(color: style.textColor),
              decoration: style.decoration('Ej: 9500', prefix: '\$ '),
              validator: (v) {
                final value = double.tryParse((v ?? '').trim());
                return (value == null || value <= 0) ? 'Ingresa un precio mayor a 0' : null;
              },
            ),
            const SizedBox(height: 16),
            const AdminFieldLabel('Categoría'),
            DropdownButtonFormField<String?>(
              value: validCategory,
              isExpanded: true,
              style: TextStyle(color: style.textColor, fontSize: 14),
              decoration: style.decoration('Sin categoría'),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('Sin categoría')),
                for (final c in categories) DropdownMenuItem<String?>(value: c.id, child: Text(c.name)),
              ],
              onChanged: (v) => setState(() => _categoryId = v),
            ),
            const SizedBox(height: 16),
            const AdminFieldLabel('Ingredientes (separados por comas)'),
            TextFormField(
              controller: _ingredients,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(color: style.textColor),
              decoration: style.decoration('Ej: Café, leche, vainilla, canela', radius: 20),
            ),
            const SizedBox(height: 8),
            // Al editar, ocultar/mostrar se hace desde la tarjeta del producto.
            if (!_isEditing)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: Text('Visible en el menú', style: TextStyle(fontSize: 14, color: style.textColor)),
                value: _isAvailable,
                onChanged: (v) => setState(() => _isAvailable = v),
              ),
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
                        _isEditing ? 'Guardar cambios' : 'Crear producto',
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
