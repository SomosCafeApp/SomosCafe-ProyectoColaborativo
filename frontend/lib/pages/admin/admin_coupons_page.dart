import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/coupon.dart';
import '../../providers/admin_coupons_provider.dart';
import '../../providers/coupons_provider.dart';
import '../../widgets/admin/admin_coupon_card.dart';
import '../../widgets/admin/admin_crud_section.dart';
import '../../widgets/admin/confirm_action_dialog.dart';
import '../../widgets/admin/coupon_form_card.dart';
import '../../widgets/profile/profile_sub_page_header.dart';

/// Sección "Cupones" del panel admin: cupones de recompensas que los
/// clientes canjean con puntos. Al crear uno (o reactivarlo) el backend
/// avisa a todos los clientes. Usa AdminCrudSection (lista + botón
/// agregar + formulario inline).
class AdminCouponsPage extends StatefulWidget {
  const AdminCouponsPage({super.key});

  @override
  State<AdminCouponsPage> createState() => _AdminCouponsPageState();
}

class _AdminCouponsPageState extends State<AdminCouponsPage> {
  bool _showForm = false;
  Coupon? _editing;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminCouponsProvider>().fetchCoupons();
    });
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Lo que ve el cliente (en este dispositivo) cambia con cualquier edición.
  void _refreshCustomerData() => context.read<CouponsProvider>().fetchAll();

  String _friendly(String? message) {
    final text = (message ?? '').toLowerCase();
    if (text.contains('redeem limit cannot be lower')) {
      return 'El límite no puede ser menor a los canjes que ya se hicieron';
    }
    if (text.contains('percentage discount cannot exceed')) return 'El porcentaje no puede superar 100%';
    if (text.contains('points cost')) return 'Los puntos deben ser un número entero mayor a 0';
    if (text.contains('coupon not found')) return 'Ese cupón ya no existe';
    if (text.contains('already an active coupon of this type')) {
      return 'Ya hay un cupón habilitado de este tipo. Deshabilítalo primero';
    }
    return message ?? 'Ocurrió un error inesperado';
  }

  void _openCreate() => setState(() {
        _editing = null;
        _showForm = true;
      });

  void _openEdit(Coupon coupon) => setState(() {
        _editing = coupon;
        _showForm = true;
      });

  void _closeForm() => setState(() {
        _showForm = false;
        _editing = null;
      });

  Future<void> _handleSubmit(CouponFormData data) async {
    final provider = context.read<AdminCouponsProvider>();
    final editing = _editing;

    final ok = editing == null
        ? await provider.createCoupon(
            kind: data.kind,
            name: data.name,
            description: data.description,
            discountType: data.discountType,
            discountValue: data.discountValue,
            maximumDiscount: data.maximumDiscount,
            minimumPurchase: data.minimumPurchase,
            pointsCost: data.pointsCost,
            redeemLimit: data.redeemLimit,
            validDays: data.validDays,
          )
        : await provider.updateCoupon(
            editing.id,
            kind: editing.kind,
            name: data.name,
            description: data.description,
            discountType: data.discountType,
            discountValue: data.discountValue,
            maximumDiscount: data.maximumDiscount,
            minimumPurchase: data.minimumPurchase,
            pointsCost: data.pointsCost,
            redeemLimit: data.redeemLimit,
            validDays: data.validDays,
          );

    if (!mounted) return;

    if (ok) {
      _closeForm();
      _snack(editing != null
          ? 'Cupón actualizado'
          : data.kind == 'REWARD'
              ? 'Cupón creado y notificado a los clientes'
              : 'Cupón creado: se entregará automáticamente');
      _refreshCustomerData();
    } else {
      // El formulario sigue abierto con lo que escribió el admin.
      _snack(_friendly(provider.errorMessage));
    }
  }

  /// Deshabilitar es directo. Habilitar un cupón deshabilitado o agotado
  /// lo REACTIVA: quienes ya lo canjearon podrán canjearlo otra vez.
  Future<void> _setActive(Coupon coupon, bool value) async {
    if (value) {
      final confirmed = await confirmAction(
        context,
        title: coupon.isGift ? 'Habilitar cupón' : 'Reactivar cupón',
        message: coupon.isGift
            ? '¿Habilitar "${coupon.name}"? Se entregará automáticamente a los clientes.'
            : 'Al reactivar "${coupon.name}" empieza una nueva ronda: quienes ya lo canjearon podrán '
                'canjearlo otra vez, el contador de canjes vuelve a 0 y se avisará a los clientes.',
        confirmLabel: coupon.isGift ? 'Sí, habilitar' : 'Sí, reactivar',
        icon: Icons.refresh_rounded,
      );
      if (!confirmed || !mounted) return;
    }

    final provider = context.read<AdminCouponsProvider>();
    final ok = await provider.setActive(coupon.id, value);

    if (!mounted) return;

    if (ok) {
      _snack(value ? (coupon.isGift ? 'Cupón habilitado' : 'Cupón reactivado y notificado') : 'Cupón deshabilitado');
      _refreshCustomerData();
    } else {
      _snack(_friendly(provider.errorMessage));
    }
  }

  Future<void> _handleDelete(Coupon coupon) async {
    final confirmed = await confirmAction(
      context,
      title: 'Eliminar cupón',
      message: '¿Eliminar "${coupon.name}"? Los clientes que ya lo canjearon conservarán su cupón.',
      confirmLabel: 'Sí, eliminar',
      destructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !mounted) return;

    final provider = context.read<AdminCouponsProvider>();
    final ok = await provider.deleteCoupon(coupon.id);

    if (!mounted) return;

    if (ok) {
      if (_editing?.id == coupon.id) _closeForm();
      _snack('Cupón eliminado');
      _refreshCustomerData();
    } else {
      _snack(_friendly(provider.errorMessage));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AdminCouponsProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          const ProfileSubPageHeader(
            title: 'Cupones',
            subtitle: 'Recompensas que se canjean con puntos',
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.fetchCoupons(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (provider.errorMessage != null && provider.coupons.isEmpty && !provider.isLoading)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)),
                      ),
                    AdminCrudSection<Coupon>(
                      addButtonLabel: 'Agregar cupón',
                      showForm: _showForm,
                      onAddPressed: _openCreate,
                      formChild: CouponFormCard(
                        // La clave fuerza un formulario nuevo al cambiar
                        // entre crear y editar (o entre dos cupones).
                        key: ValueKey(_editing?.id ?? 'new'),
                        initial: _editing,
                        isSubmitting: provider.isSubmitting,
                        onClose: _closeForm,
                        onSubmit: _handleSubmit,
                      ),
                      isLoading: provider.isLoading,
                      items: provider.coupons,
                      emptyText: 'Todavía no hay cupones.',
                      itemBuilder: (context, coupon) => AdminCouponCard(
                        coupon: coupon,
                        isBusy: provider.busyCouponId == coupon.id,
                        onToggleActive: (value) => _setActive(coupon, value),
                        onReactivate: () => _setActive(coupon, true),
                        onEdit: () => _openEdit(coupon),
                        onDelete: () => _handleDelete(coupon),
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
