import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/address_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import 'addresses_page.dart';
import 'order_success_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? _selectedAddressId;
  String _selectedPaymentMethod = 'Efectivo';

  static const _paymentLabels = {
    'Efectivo': 'Efectivo contra entrega',
    'Transferencia': 'Nequi / Daviplata',
    'Tarjeta': 'Tarjeta de Crédito / Débito',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addressProvider = context.read<AddressProvider>();
      if (addressProvider.addresses.isEmpty) {
        addressProvider.fetchAddresses();
      }
      _preselectDefaultAddress();
    });
  }

  void _preselectDefaultAddress() {
    final addresses = context.read<AddressProvider>().addresses;
    if (addresses.isEmpty) return;
    final defaultAddress = addresses.firstWhere(
      (a) => a.isDefault,
      orElse: () => addresses.first,
    );
    setState(() => _selectedAddressId = defaultAddress.id);
  }

  Future<void> _submitOrder(CartProvider cart) async {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una dirección de entrega')),
      );
      return;
    }

    final orderProvider = context.read<OrderProvider>();
    final order = await orderProvider.createOrder(
      addressId: _selectedAddressId!,
      lines: cart.lines,
      notes: 'Método de pago: ${_paymentLabels[_selectedPaymentMethod]}',
    );

    if (!mounted) return;

    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(orderProvider.errorMessage ?? 'No se pudo crear el pedido')),
      );
      return;
    }

    await context.read<CartProvider>().clearCart();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => OrderSuccessPage(order: order)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final addressProvider = context.watch<AddressProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Finalizar Pedido'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dirección de Entrega',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),

            if (addressProvider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (addressProvider.addresses.isEmpty)
              _buildNoAddressCard(theme, isDark)
            else
              _buildAddressSelector(addressProvider, theme, isDark),

            const SizedBox(height: 24),

            Text(
              'Método de Pago',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),

            _buildCustomRadio(
              title: 'Efectivo contra entrega',
              value: 'Efectivo',
              theme: theme,
            ),

            _buildCustomRadio(
              title: 'Nequi / Daviplata',
              value: 'Transferencia',
              theme: theme,
            ),

            _buildCustomRadio(
              title: 'Tarjeta de Crédito / Débito',
              value: 'Tarjeta',
              theme: theme,
            ),

            const SizedBox(height: 8),
            Text(
              'Nota: el cobro real todavía se hace fuera de la app; '
              'esto solo queda registrado en el pedido.',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white54 : Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF332B1E)
                    : const Color(0xFFFDF6E2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? Colors.white12
                      : const Color(0xFFF3E5AB),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total a Pagar:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '\$${cart.total.toStringAsFixed(0)} COP',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: orderProvider.isCreating ? null : () => _submitOrder(cart),
          child: orderProvider.isCreating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text(
                  'Pagar y Realizar Pedido',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildNoAddressCard(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_off_outlined, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Aún no tienes direcciones guardadas.',
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ),
          TextButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddressesPage()),
              );
              if (mounted) _preselectDefaultAddress();
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSelector(AddressProvider addressProvider, ThemeData theme, bool isDark) {
    return Column(
      children: [
        ...addressProvider.addresses.map((address) {
          final isSelected = _selectedAddressId == address.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InkWell(
              onTap: () => setState(() => _selectedAddressId = address.id),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? Colors.white24 : Colors.grey.shade300),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Radio<String>(
                      value: address.id,
                      groupValue: _selectedAddressId,
                      activeColor: AppColors.primary,
                      onChanged: (val) => setState(() => _selectedAddressId = val),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address.label,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '${address.address}, ${address.details}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddressesPage()),
              );
              if (mounted) context.read<AddressProvider>().fetchAddresses();
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Agregar otra dirección'),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomRadio({
    required String title,
    required String value,
    required ThemeData theme,
  }) {
    final isSelected = _selectedPaymentMethod == value;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPaymentMethod = value;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark
                      ? Colors.white24
                      : Colors.grey.shade300),
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? (isDark
                    ? const Color(0xFF332B1E).withOpacity(0.5)
                    : const Color(0xFFFDF6E2).withOpacity(0.5))
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Radio<String>(
                value: value,
                groupValue: _selectedPaymentMethod,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  if (val == null) return;

                  setState(() {
                    _selectedPaymentMethod = val;
                  });
                },
              ),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: theme.colorScheme.onSurface,
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
