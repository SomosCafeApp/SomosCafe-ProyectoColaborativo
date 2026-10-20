import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/product_model.dart';

/// Hoja inferior para elegir los productos a los que aplica una promoción
/// (búsqueda, seleccionar/quitar todos y lista perezosa).
class PromotionProductPickerSheet extends StatefulWidget {
  final List<Product> products;
  final Set<String> selected;

  const PromotionProductPickerSheet({super.key, required this.products, required this.selected});

  @override
  State<PromotionProductPickerSheet> createState() => _PromotionProductPickerSheetState();
}

class _PromotionProductPickerSheetState extends State<PromotionProductPickerSheet> {
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
