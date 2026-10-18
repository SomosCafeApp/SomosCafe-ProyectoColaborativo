import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import 'transfer_payment_page.dart';
import '../widgets/profile/profile_sub_page_header.dart';
import '../widgets/orders/order_card_item.dart';
import '../widgets/orders/empty_orders_view.dart';
import '../widgets/common/styled_confirm_dialog.dart';

import '../animations/animations.dart';
class OrdersPage extends StatefulWidget {
  final VoidCallback? onExploreMenu;

  const OrdersPage({
    super.key,
    this.onExploreMenu,
  });

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String? _expandedOrderId;
  String? _cancellingOrderId;

  Timer? _ticker;
  int _secondsSinceRefresh = 0;

  // Cada cuánto se vuelve a pedir la lista al backend para reflejar
  // los cambios de estado que hace el administrador.
  static const _refreshEverySeconds = 15;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderProvider = context.read<OrderProvider>();

      // Siempre refrescamos al abrir: el admin pudo cambiar estados.
      orderProvider.fetchOrders(silent: orderProvider.orders.isNotEmpty);
    });

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      final orderProvider = context.read<OrderProvider>();
      _secondsSinceRefresh++;

      if (_secondsSinceRefresh >= _refreshEverySeconds) {
        _secondsSinceRefresh = 0;
        orderProvider.fetchOrders(silent: true);
        return;
      }

      // Redibuja para mover la cuenta regresiva de cancelación y
      // ocultar el botón apenas se acaba el tiempo.
      // (incluye 2 s de margen para que el botón desaparezca justo al
      // llegar a 00:00 y no se quede congelado).
      final threshold = DateTime.now().subtract(const Duration(seconds: 2));
      final hasActiveWindow = orderProvider.orders.any(
        (o) => o.status.isCancellable && o.cancelDeadline != null && o.cancelDeadline!.isAfter(threshold),
      );
      if (hasActiveWindow) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _handleCancel(Order order) async {
    final confirmed = await showStyledConfirmDialog(
      context,
      icon: Icons.cancel_outlined,
      title: 'Cancelar pedido',
      message: '¿Seguro que quieres cancelar este pedido?',
      confirmLabel: 'Sí, cancelar',
      cancelLabel: 'No',
    );

    if (!confirmed) return;

    setState(() {
      _cancellingOrderId = order.id;
    });

    final success = await context
        .read<OrderProvider>()
        .cancelOrder(order.id);

    if (!mounted) return;

    setState(() {
      _cancellingOrderId = null;
    });

    if (!success) {
      final error = context.read<OrderProvider>().errorMessage;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error ?? 'No se pudo cancelar el pedido',
          ),
        ),
      );
    }
  }

  void _handleReorder(Order order) {
    final cartProvider = context.read<CartProvider>();

    for (final item in order.items) {
      final product = Product(
        id: item.productId,
        name: item.name,
        description: '',
        price: item.price,
        imageUrl: item.image,
      );

      cartProvider.addToCart(
        product,
        quantity: item.quantity,
        customization: item.customization,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Productos del pedido agregados al carrito',
        ),
      ),
    );
  }

  /// Pedido por transferencia al que aún le falta el comprobante.
  void _openPayment(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TransferPaymentPage(order: order)),
    );
  }

  void _handleExploreMenu() {
    if (widget.onExploreMenu != null) {
      widget.onExploreMenu!();
      return;
    }

    // Si no se proporciona un callback, simplemente
    // regresamos a la pantalla anterior para conservar
    // el MainNavigationScreen y su navbar.
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderProvider = context.watch<OrderProvider>();
    final orders = orderProvider.orders;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          const ProfileSubPageHeader(
            title: 'Mis Pedidos',
            subtitle: 'Sigue el estado de tus compras',
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => orderProvider.fetchOrders(),
              child: _buildBody(
                orderProvider,
                orders,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    OrderProvider orderProvider,
    List<Order> orders,
  ) {
    if (orderProvider.isLoading && orders.isEmpty) {
      return const Center(child: CoffeeCupLoader());
    }

    if (orderProvider.errorMessage != null && orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Center(
            child: Text(
              orderProvider.errorMessage!,
              style: const TextStyle(
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    if (orders.isEmpty) {
      return EmptyOrdersView(
        onExploreMenu: _handleExploreMenu,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];

        return OrderCardItem(
          order: order,
          isExpanded: _expandedOrderId == order.id,
          isCancelling: _cancellingOrderId == order.id,
          onTap: () {
            setState(() {
              _expandedOrderId =
                  _expandedOrderId == order.id
                      ? null
                      : order.id;
            });
          },
          onReorder: () => _handleReorder(order),
          onPay: order.needsProof ? () => _openPayment(order) : null,
          onCancel: order.canCancel
              ? () => _handleCancel(order)
              : null,
        );
      },
    );
  }
}