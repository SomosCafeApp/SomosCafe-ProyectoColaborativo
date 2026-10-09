import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/admin_products_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/admin/admin_crud_section.dart';
import '../../widgets/admin/admin_search_field.dart';
import '../../widgets/admin/product/admin_product_card.dart';
import '../../widgets/admin/product/product_dialogs.dart';
import '../../widgets/admin/product/product_form_card.dart';
import '../../widgets/profile/profile_sub_page_header.dart';

/// Sección "Productos" del panel admin: lista de todos los productos
/// (incluidos los ocultos), formulario con imagen (Cloudinary),
/// ocultar/mostrar del menú, editar y eliminar definitivamente.
class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  bool _showForm = false;
  Product? _editing;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProductsProvider>().fetchProducts();

      // El formulario necesita las categorías para el selector.
      final catalog = context.read<ProductProvider>();
      if (catalog.categories.isEmpty) catalog.fetchCategories();
    });
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Lo que ve el cliente (menú, home) cambia con cualquier edición.
  void _refreshCustomerData() => context.read<ProductProvider>().fetchProducts();

  String _friendly(String? message) {
    final text = (message ?? '').toLowerCase();
    if (text.contains('image is required')) return 'La imagen del producto es obligatoria';
    if (text.contains('category not found')) return 'La categoría seleccionada ya no existe';
    if (text.contains('category is inactive')) return 'La categoría seleccionada está inactiva';
    if (text.contains('only jpg')) return 'Formato no permitido. Usa JPG, PNG, WEBP o AVIF';
    if (text.contains('file too large')) return 'La imagen supera los 5 MB';
    return message ?? 'Ocurrió un error inesperado';
  }

  void _openForm([Product? product]) => setState(() {
        _editing = product;
        _showForm = true;
      });

  void _closeForm() => setState(() {
        _showForm = false;
        _editing = null;
      });

  Future<void> _handleSubmit(ProductFormData data) async {
    final provider = context.read<AdminProductsProvider>();
    final editing = _editing;

    final ok = editing == null
        ? await provider.createProduct(
            name: data.name,
            description: data.description,
            price: data.price,
            ingredients: data.ingredients,
            categoryId: data.categoryId,
            isAvailable: data.isAvailable,
            image: data.image!,
          )
        : await provider.updateProduct(
            editing.id,
            name: data.name,
            description: data.description,
            price: data.price,
            ingredients: data.ingredients,
            categoryId: data.categoryId,
            image: data.image,
          );

    if (!mounted) return;

    if (ok) {
      _closeForm();
      _snack(editing == null ? 'Producto creado' : 'Producto actualizado');
      _refreshCustomerData();
    } else {
      // El formulario sigue abierto con lo que escribió el admin.
      _snack(_friendly(provider.errorMessage));
    }
  }

  Future<void> _setAvailability(Product product, bool value) async {
    final provider = context.read<AdminProductsProvider>();
    final ok = await provider.setAvailability(product.id, value);

    if (!mounted) return;

    if (ok) {
      _snack(value ? '"${product.name}" vuelve a estar en el menú' : '"${product.name}" ya no aparece en el menú');
      _refreshCustomerData();
    } else {
      _snack(_friendly(provider.errorMessage));
    }
  }

  Future<void> _handleDelete(Product product) async {
    final choice = await askDeleteProduct(context, product.name);
    if (!mounted) return;

    switch (choice) {
      case DeleteProductChoice.cancel:
        return;
      case DeleteProductChoice.hide:
        return _setAvailability(product, false);
      case DeleteProductChoice.delete:
        final provider = context.read<AdminProductsProvider>();
        final ok = await provider.deleteProduct(product.id);
        if (!mounted) return;
        if (ok) {
          if (_editing?.id == product.id) _closeForm();
          _snack('Producto eliminado');
          _refreshCustomerData();
        } else {
          _snack(_friendly(provider.errorMessage));
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProductsProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const ProfileSubPageHeader(title: 'Productos', subtitle: 'Menú, precios e imágenes'),
          Expanded(
            child: RefreshIndicator(
              onRefresh: provider.fetchProducts,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (provider.errorMessage != null && provider.products.isEmpty && !provider.isLoading)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)),
                      ),
                    if (!_showForm && provider.products.isNotEmpty)
                      AdminSearchField(
                        hint: 'Buscar por nombre o categoría',
                        onChanged: provider.setSearchQuery,
                      ),
                    AdminCrudSection<Product>(
                      addButtonLabel: 'Agregar producto',
                      showForm: _showForm,
                      onAddPressed: _openForm,
                      formChild: ProductFormCard(
                        key: ValueKey(_editing?.id ?? 'new'),
                        initial: _editing,
                        isSubmitting: provider.isSubmitting,
                        onClose: _closeForm,
                        onSubmit: _handleSubmit,
                      ),
                      isLoading: provider.isLoading,
                      items: provider.filteredProducts,
                      emptyText: provider.products.isEmpty
                          ? 'Todavía no hay productos.'
                          : 'Ningún producto coincide con la búsqueda.',
                      itemBuilder: (context, product) => AdminProductCard(
                        product: product,
                        isBusy: provider.busyProductId == product.id,
                        onToggleAvailability: () => _setAvailability(product, !product.isAvailable),
                        onEdit: () => _openForm(product),
                        onDelete: () => _handleDelete(product),
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
