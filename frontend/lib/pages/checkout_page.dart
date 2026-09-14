import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';

import 'order_success_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _addressController = TextEditingController();

  String _selectedPaymentMethod = 'Efectivo';

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
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

            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Ej: Calle 7 # 10-20, Barrio Centro',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey.shade400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                prefixIcon: const Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                ),
              ),
            ),

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
          onPressed: () {
            // Validar dirección
            if (_addressController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Por favor ingresa una dirección de entrega',
                  ),
                ),
              );
              return;
            }

            // Crear pedido
            context.read<OrderProvider>().addOrder(
                  items: cart.items,
                  total: cart.total,
                  address: _addressController.text.trim(),
                  paymentMethod: _selectedPaymentMethod,
                );

            // Vaciar carrito
            context.read<CartProvider>().clearCart();

            // Ir a pantalla de pedido exitoso
            //
            // IMPORTANTE:
            // No usamos pushAndRemoveUntil porque eliminaría
            // todas las rutas anteriores.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const OrderSuccessPage(),
              ),
            );
          },
          child: const Text(
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