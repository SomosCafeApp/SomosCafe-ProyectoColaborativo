import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/order.dart';
import '../../providers/admin_orders_provider.dart';
import '../../widgets/admin/admin_order_card.dart';
import '../../widgets/admin/admin_order_filter_chips.dart';
import '../../widgets/admin/admin_search_bar.dart';
import '../../widgets/admin/confirm_action_dialog.dart';
import '../../widgets/profile/profile_sub_page_header.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final TextEditingController _searchController = TextEditingController();

  String? _expandedOrderId;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminOrdersProvider>().fetchOrders();
    });

    _refreshTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) {
        if (mounted) {
          context.read<AdminOrdersProvider>().fetchOrders(silent: true);
        }
      },
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _snack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Ejecuta una acción del provider y muestra el resultado: el mensaje
  /// de éxito, o el motivo del error que dejó el provider.
  Future<void> _run(
    Future<bool> Function() action, {
    required String success,
    required String failure,
  }) async {
    final provider = context.read<AdminOrdersProvider>();
    final ok = await action();
    if (!mounted) return;
    _snack(ok ? success : (provider.errorMessage ?? failure));
  }

  Future<void> _handleChangeStatus(Order order, OrderStatus status) async {
    if (status == OrderStatus.cancelled) {
      final confirmed = await confirmAction(
        context,
        title: 'Cancelar pedido',
        message: '¿Cancelar el pedido #${order.shortId}? El cliente recibirá una notificación.',
        confirmLabel: 'Sí, cancelar',
        destructive: true,
      );
      if (!confirmed || !mounted) return;
    }

    final provider = context.read<AdminOrdersProvider>();
    await _run(
      () => provider.updateStatus(order.id, status),
      success: 'Pedido #${order.shortId}: ${status.label}',
      failure: 'No se pudo cambiar el estado',
    );
  }

  Future<void> _handleValidatePayment(Order order) async {
    final confirmed = await confirmAction(
      context,
      title: 'Validar pago',
      message: '¿Confirmas que el pago de ${_money(order.total)} del pedido #${order.shortId} '
          'llegó a tu cuenta? Se avisará al cliente y el pedido pasará a Confirmado.',
      confirmLabel: 'Sí, validar',
    );
    if (!confirmed || !mounted) return;

    final provider = context.read<AdminOrdersProvider>();
    await _run(
      () => provider.validatePayment(order.id),
      success: 'Pago validado. Se notificó al cliente.',
      failure: 'No se pudo validar el pago',
    );
  }

  Future<void> _handleInvalidatePayment(Order order) async {
    final confirmed = await confirmAction(
      context,
      title: 'Invalidar pago',
      message: '¿El comprobante del pedido #${order.shortId} es falso o no corresponde? '
          'El pedido se cancelará automáticamente y se notificará al cliente.',
      confirmLabel: 'Sí, invalidar',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    final provider = context.read<AdminOrdersProvider>();
    await _run(
      () => provider.invalidatePayment(order.id),
      success: 'Pago invalidado. El pedido fue cancelado y se notificó al cliente.',
      failure: 'No se pudo invalidar el pago',
    );
  }

  Future<void> _handleDelete(Order order) async {
    final confirmed = await confirmAction(
      context,
      title: 'Eliminar pedido',
      message: '¿Eliminar definitivamente el pedido #${order.shortId}?',
      confirmLabel: 'Sí, eliminar',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    final provider = context.read<AdminOrdersProvider>();
    await _run(
      () => provider.deleteOrder(order.id),
      success: 'Pedido eliminado',
      failure: 'No se pudo eliminar el pedido',
    );
  }

  String _money(double value) => '\$${value.toStringAsFixed(0)} COP';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AdminOrdersProvider>();
    final List<Order> orders = provider.filteredOrders;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          const ProfileSubPageHeader(
            title: 'Pedidos',
            subtitle: 'Gestiona los pedidos de todos los clientes',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                AdminSearchBar(
                  controller: _searchController,
                  hint: 'Buscar por pedido, cliente, correo o teléfono...',
                  onChanged: provider.setSearchQuery,
                ),
                const SizedBox(height: 10),
                AdminOrderFilterChips(
                  provider: provider,
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.fetchOrders(),
              child: _buildBody(
                provider,
                orders,
                theme,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    AdminOrdersProvider provider,
    List<Order> orders,
    ThemeData theme,
  ) {
    final subtitleColor = theme.brightness == Brightness.dark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    if (provider.isLoading && provider.orders.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.errorMessage != null && provider.orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    if (orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Center(
            child: Text(
              provider.orders.isEmpty
                  ? 'Todavía no hay pedidos.'
                  : 'Ningún pedido coincide con la búsqueda.',
              style: TextStyle(
                color: subtitleColor,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final Order order = orders[index];

        return AdminOrderCard(
          order: order,
          isExpanded: _expandedOrderId == order.id,
          isBusy: provider.busyOrderId == order.id,
          onTap: () {
            setState(() {
              _expandedOrderId =
                  _expandedOrderId == order.id ? null : order.id;
            });
          },
          onChangeStatus: (status) => _handleChangeStatus(order, status),
          onValidatePayment: () => _handleValidatePayment(order),
          onInvalidatePayment: () => _handleInvalidatePayment(order),
          onDelete: () => _handleDelete(order),
        );
      },
    );
  }
}