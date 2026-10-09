import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../providers/address_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/payment_method_provider.dart';
import '../widgets/order_confirmation/address_picker_section.dart';
import '../widgets/order_confirmation/confirm_order_bar.dart';
import '../widgets/order_confirmation/confirm_section_title.dart';
import '../widgets/order_confirmation/delivery_type_selector.dart';
import '../widgets/order_confirmation/order_summary_card.dart';
import '../widgets/order_confirmation/payment_picker_section.dart';
import '../widgets/order_confirmation/recipient_fields.dart';
import 'order_success_page.dart';

/// Pantalla que se abre al pulsar "Realizar pedido" en el carrito.
/// Recoge tipo de entrega, receptor, dirección, método de pago y nota,
/// muestra el resumen y, solo al pulsar "Confirmar pedido", crea la
/// orden. El carrito se vacía únicamente si la creación fue exitosa.
///
/// Los montos que se ven aquí son informativos: el backend recalcula
/// precios, personalizaciones, envío, descuento y total.
class OrderConfirmationPage extends StatefulWidget {
  const OrderConfirmationPage({super.key});

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  DeliveryType _deliveryType = DeliveryType.delivery;
  String? _selectedAddressId;
  String? _selectedPaymentMethodId;

  // Si el usuario escribe el receptor a mano, ya no lo pisamos al
  // cambiar de dirección.
  bool _recipientEdited = false;
  bool _fillingRecipient = false;

  @override
  void initState() {
    super.initState();

    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _setRecipient('${user.name} ${user.lastName}'.trim(), user.phone);
    }

    _nameController.addListener(_markEdited);
    _phoneController.addListener(_markEdited);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final addresses = context.read<AddressProvider>();
      final methods = context.read<PaymentMethodProvider>();
      if (addresses.addresses.isEmpty) await addresses.fetchAddresses();
      if (methods.methods.isEmpty) await methods.fetchPaymentMethods();
      if (!mounted) return;
      _preselectAddress();
      _preselectPaymentMethod();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _markEdited() {
    if (!_fillingRecipient) _recipientEdited = true;
  }

  void _setRecipient(String name, String phone) {
    _fillingRecipient = true;
    _nameController.text = name;
    _phoneController.text = phone;
    _fillingRecipient = false;
  }

  void _preselectAddress() {
    final addresses = context.read<AddressProvider>().addresses;
    if (addresses.isEmpty) return;
    if (_selectedAddressId != null && addresses.any((a) => a.id == _selectedAddressId)) return;
    final chosen = addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
    _selectAddress(chosen.id);
  }

  void _preselectPaymentMethod() {
    final methods = context.read<PaymentMethodProvider>().methods;
    if (methods.isEmpty) return;
    if (_selectedPaymentMethodId != null && methods.any((m) => m.id == _selectedPaymentMethodId)) return;
    final chosen = methods.firstWhere((m) => m.isDefault, orElse: () => methods.first);
    setState(() => _selectedPaymentMethodId = chosen.id);
  }

  void _selectAddress(String id) {
    setState(() => _selectedAddressId = id);

    // Sugerimos el receptor de la dirección mientras no se haya editado.
    if (!_recipientEdited) {
      final address = context.read<AddressProvider>().addresses.firstWhere((a) => a.id == id);
      if (address.recipientName.isNotEmpty || address.phone.isNotEmpty) {
        _setRecipient(address.recipientName, address.phone);
      }
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_deliveryType == DeliveryType.delivery && _selectedAddressId == null) {
      _snack('Selecciona una dirección de entrega');
      return;
    }

    if (_selectedPaymentMethodId == null) {
      _snack('Selecciona un método de pago');
      return;
    }

    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();

    if (cart.hasUnavailableLines) {
      _snack('Quita del carrito los productos que ya no están disponibles');
      return;
    }

    final order = await orderProvider.createOrder(
      lines: cart.lines,
      deliveryType: _deliveryType,
      recipientName: _nameController.text,
      recipientPhone: _phoneController.text,
      addressId: _selectedAddressId,
      paymentMethodId: _selectedPaymentMethodId!,
      notes: _notesController.text,
    );

    if (!mounted) return;

    if (order == null) {
      // El carrito NO se toca: el usuario puede corregir y reintentar.
      _snack(orderProvider.errorMessage ?? 'No se pudo crear el pedido');
      return;
    }

    // Creación exitosa: el backend ya vació el carrito del servidor;
    // aquí limpiamos la copia local.
    cart.clearLocal();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => OrderSuccessPage(order: order)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final theme = Theme.of(context);

    // Subtotal antes de descuento; el descuento sale de las promociones
    // vigentes. Todo es informativo: el backend recalcula al confirmar.
    final subtotal = cart.subtotal;
    final shipping = _deliveryType.shippingFee;
    final discount = cart.discount;
    final total = subtotal + shipping - discount;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Confirmar pedido')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const ConfirmSectionTitle('Tipo de entrega'),
            DeliveryTypeSelector(
              selected: _deliveryType,
              onChanged: (type) => setState(() => _deliveryType = type),
            ),
            const SizedBox(height: 24),
            const ConfirmSectionTitle('Quién recibe'),
            RecipientFields(nameController: _nameController, phoneController: _phoneController),
            if (_deliveryType == DeliveryType.delivery) ...[
              const SizedBox(height: 24),
              const ConfirmSectionTitle('Dirección de entrega'),
              AddressPickerSection(
                selectedId: _selectedAddressId,
                onSelected: _selectAddress,
                onAfterManage: _preselectAddress,
              ),
            ],
            const SizedBox(height: 24),
            const ConfirmSectionTitle('Método de pago'),
            PaymentPickerSection(
              selectedId: _selectedPaymentMethodId,
              onSelected: (id) => setState(() => _selectedPaymentMethodId = id),
              onAfterManage: _preselectPaymentMethod,
            ),
            const SizedBox(height: 24),
            const ConfirmSectionTitle('Nota del pedido'),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              maxLength: 300,
              decoration: const InputDecoration(
                hintText: 'Ej.: sin azúcar, tocar el timbre dos veces…',
                prefixIcon: Icon(Icons.sticky_note_2_outlined),
              ),
            ),
            const SizedBox(height: 12),
            const ConfirmSectionTitle('Resumen'),
            if (cart.hasUnavailableLines)
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Algunos productos ya no están disponibles. Quítalos del carrito para continuar.',
                  style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.w600),
                ),
              ),
            OrderSummaryCard(
              lines: cart.lines,
              subtotal: subtotal,
              shipping: shipping,
              discount: discount,
              total: total,
            ),
          ],
        ),
      ),
      bottomNavigationBar: ConfirmOrderBar(
        total: total,
        isLoading: orderProvider.isCreating,
        enabled: !cart.isEmpty && !cart.hasUnavailableLines,
        onConfirm: _confirm,
      ),
    );
  }
}
