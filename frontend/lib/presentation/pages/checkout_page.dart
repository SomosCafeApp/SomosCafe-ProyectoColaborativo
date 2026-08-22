import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/cart_provider.dart';
import '../state/order_provider.dart'; // <-- Conexión agregada
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalizar Pedido'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dirección de Entrega',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                hintText: 'Ej: Calle 7 # 10-20, Barrio Centro',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Método de Pago',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            RadioListTile<String>(
              title: const Text('Efectivo contra entrega'),
              value: 'Efectivo',
              groupValue: _selectedPaymentMethod,
              onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
            ),
            RadioListTile<String>(
              title: const Text('Nequi / Daviplata'),
              value: 'Transferencia',
              groupValue: _selectedPaymentMethod,
              onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
            ),
            RadioListTile<String>(
              title: const Text('Tarjeta de Crédito / Débito'),
              value: 'Tarjeta',
              groupValue: _selectedPaymentMethod,
              onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.brown[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total a Pagar:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      '\$${cart.total.toStringAsFixed(0)} COP',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown[800]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4E342E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            if (_addressController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Por favor ingresa una dirección de entrega')),
              );
              return;
            }

            // <-- Guardamos el pedido en el OrderProvider antes de limpiar el carrito
            context.read<OrderProvider>().addOrder(
              items: cart.items,
              total: cart.total,
              address: _addressController.text,
              paymentMethod: _selectedPaymentMethod,
            );

            context.read<CartProvider>().clearCart();

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const OrderSuccessPage()),
              (route) => false,
            );
          },
          child: const Text('Pagar y Realizar Pedido', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}