import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/promotion.dart';
import '../../providers/admin_promotions_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/promo_of_the_day_provider.dart';
import '../../widgets/admin/admin_crud_section.dart';
import '../../widgets/admin/admin_promotion_card.dart';
import '../../widgets/admin/confirm_action_dialog.dart';
import '../../widgets/admin/promotion_form_card.dart';
import '../../widgets/profile/profile_sub_page_header.dart';

/// Sección "Promociones" del panel admin. Usa AdminCrudSection (lista +
/// botón agregar + formulario inline). Cada promoción se puede
/// habilitar/deshabilitar, editar, eliminar y marcar como promo del día.
class AdminPromotionsPage extends StatefulWidget {
  const AdminPromotionsPage({super.key});

  @override
  State<AdminPromotionsPage> createState() => _AdminPromotionsPageState();
}

class _AdminPromotionsPageState extends State<AdminPromotionsPage> {
  bool _showForm = false;
  Promotion? _editing;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminPromotionsProvider>().fetchPromotions();

      // El selector de productos usa el catálogo ya cargado.
      final products = context.read<ProductProvider>();
      if (products.products.isEmpty) products.fetchProducts();
    });
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Los precios con descuento y la promo del día cambian con cualquier
  /// edición: recargamos lo que ve el cliente (en este dispositivo).
  void _refreshCustomerData() {
    context.read<ProductProvider>().fetchProducts();
    context.read<PromoOfTheDayProvider>().fetchPromo();
  }

  String _friendly(String? message) {
    final text = (message ?? '').toLowerCase();
    if (text.contains('code already exists')) return 'Ya existe una promoción con ese código';
    if (text.contains('products were not found')) return 'Alguno de los productos ya no existe';
    if (text.contains('end date must be greater')) return 'La fecha final debe ser posterior a la inicial';
    if (text.contains('enable the promotion')) return 'Habilita la promoción antes de hacerla promo del día';
    return message ?? 'Ocurrió un error inesperado';
  }

  void _openCreate() => setState(() {
        _editing = null;
        _showForm = true;
      });

  void _openEdit(Promotion promotion) => setState(() {
        _editing = promotion;
        _showForm = true;
      });

  void _closeForm() => setState(() {
        _showForm = false;
        _editing = null;
      });

  Future<void> _handleSubmit(PromotionFormData data) async {
    final provider = context.read<AdminPromotionsProvider>();
    final editing = _editing;

    final ok = editing == null
        ? await provider.createPromotion(
            code: data.code,
            name: data.name,
            description: data.description,
            discountType: data.discountType,
            discountValue: data.discountValue,
            maximumDiscount: data.maximumDiscount,
            productIds: data.productIds,
            startDate: data.startDate,
            endDate: data.endDate,
          )
        : await provider.updatePromotion(
            editing.id,
            code: data.code,
            name: data.name,
            description: data.description,
            discountType: data.discountType,
            discountValue: data.discountValue,
            maximumDiscount: data.maximumDiscount,
            productIds: data.productIds,
            startDate: data.startDate,
            endDate: data.endDate,
          );

    if (!mounted) return;

    if (ok) {
      _closeForm();
      _snack(editing == null ? 'Promoción creada' : 'Promoción actualizada');
      _refreshCustomerData();
    } else {
      // El formulario sigue abierto con lo que escribió el admin.
      _snack(_friendly(provider.errorMessage));
    }
  }

  Future<void> _handleToggleActive(Promotion promotion, bool value) async {
    final provider = context.read<AdminPromotionsProvider>();
    final ok = await provider.setActive(promotion.id, value);

    if (!mounted) return;

    if (ok) {
      _snack(value ? 'Promoción habilitada' : 'Promoción deshabilitada');
      _refreshCustomerData();
    } else {
      _snack(_friendly(provider.errorMessage));
    }
  }

  Future<void> _handleTogglePromoOfTheDay(Promotion promotion) async {
    final provider = context.read<AdminPromotionsProvider>();
    final value = !promotion.isPromoOfTheDay;
    final ok = await provider.setPromoOfTheDay(promotion.id, value);

    if (!mounted) return;

    if (ok) {
      _snack(value ? '"${promotion.name}" es ahora la promo del día' : 'Ya no hay promo del día');
      _refreshCustomerData();
    } else {
      _snack(_friendly(provider.errorMessage));
    }
  }

  Future<void> _handleDelete(Promotion promotion) async {
    final confirmed = await confirmAction(
      context,
      title: 'Eliminar promoción',
      message: '¿Eliminar "${promotion.name}"? Los productos asignados volverán a su precio normal.',
      confirmLabel: 'Sí, eliminar',
      destructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !mounted) return;

    final provider = context.read<AdminPromotionsProvider>();
    final ok = await provider.deletePromotion(promotion.id);

    if (!mounted) return;

    if (ok) {
      if (_editing?.id == promotion.id) _closeForm();
      _snack('Promoción eliminada');
      _refreshCustomerData();
    } else {
      _snack(_friendly(provider.errorMessage));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AdminPromotionsProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          const ProfileSubPageHeader(
            title: 'Promociones',
            subtitle: 'Descuentos y promo del día',
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.fetchPromotions(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (provider.errorMessage != null && provider.promotions.isEmpty && !provider.isLoading)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)),
                      ),
                    AdminCrudSection<Promotion>(
                      addButtonLabel: 'Agregar promoción',
                      showForm: _showForm,
                      onAddPressed: _openCreate,
                      formChild: PromotionFormCard(
                        // La clave fuerza un formulario nuevo al cambiar
                        // entre crear y editar (o entre dos promociones).
                        key: ValueKey(_editing?.id ?? 'new'),
                        initial: _editing,
                        isSubmitting: provider.isSubmitting,
                        onClose: _closeForm,
                        onSubmit: _handleSubmit,
                      ),
                      isLoading: provider.isLoading,
                      items: provider.promotions,
                      emptyText: 'Todavía no hay promociones.',
                      itemBuilder: (context, promotion) => AdminPromotionCard(
                        promotion: promotion,
                        isBusy: provider.busyPromotionId == promotion.id,
                        onToggleActive: (value) => _handleToggleActive(promotion, value),
                        onTogglePromoOfTheDay: () => _handleTogglePromoOfTheDay(promotion),
                        onEdit: () => _openEdit(promotion),
                        onDelete: () => _handleDelete(promotion),
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
