import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/order.dart';
import '../../providers/admin_orders_provider.dart';
import '../../widgets/admin/admin_order_card.dart';
import '../../widgets/admin/admin_order_filter_chips.dart';
import '../../widgets/admin/admin_order_search_bar.dart';
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
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> _handleChangeStatus(
    Order order,
    OrderStatus status,
  ) async {
    if (status == OrderStatus.cancelled) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Cancelar pedido'),
          content: Text(
            '¿Cancelar el pedido #${order.shortId}? '
            'El cliente recibirá una notificación.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sí, cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('No'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    if (!mounted) return;

    final provider = context.read<AdminOrdersProvider>();

    final ok = await provider.updateStatus(
      order.id,
      status,
    );

    if (!mounted) return;

    _snack(
      ok
          ? 'Pedido #${order.shortId}: ${status.label}'
          : (provider.errorMessage ?? 'No se pudo cambiar el estado'),
    );
  }

  Future<void> _handleDelete(Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar pedido'),
        content: Text(
          '¿Eliminar definitivamente el pedido #${order.shortId}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí, eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<AdminOrdersProvider>();

    final ok = await provider.deleteOrder(order.id);

    if (!mounted) return;

    _snack(
      ok
          ? 'Pedido eliminado'
          : (provider.errorMessage ?? 'No se pudo eliminar el pedido'),
    );
  }

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
                AdminOrderSearchBar(
                  controller: _searchController,
                  searchQuery: provider.searchQuery,
                  onChanged: (value) {
                    provider.setSearchQuery(value);
                  },
                  onClear: () {
                    _searchController.clear();
                    provider.setSearchQuery('');
                  },
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
          onChangeStatus: (status) {
            _handleChangeStatus(order, status);
          },
          onDelete: () {
            _handleDelete(order);
          },
        );
      },
    );
  }
}