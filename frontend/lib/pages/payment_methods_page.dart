import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/payment_method_provider.dart';
import '../widgets/profile/profile_sub_page_header.dart';
import '../widgets/payment_methods/saved_payment_methods_section.dart';
import '../widgets/payment_methods/payment_method_form_card.dart';
import '../widgets/payment_methods/other_payment_options_section.dart';
import '../widgets/payment_methods/secure_payment_info_card.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  bool _showCardForm = false;
  final _nameController = TextEditingController();
  final _last4Controller = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();
  String? _formError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PaymentMethodProvider>();
      if (provider.methods.isEmpty) provider.fetchPaymentMethods();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _last4Controller.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _closeCardForm() {
    setState(() {
      _showCardForm = false;
      _formError = null;
      _nameController.clear();
      _last4Controller.clear();
      _monthController.clear();
      _yearController.clear();
    });
  }

  Future<void> _saveCard() async {
    final last4 = _last4Controller.text.trim();
    final month = int.tryParse(_monthController.text.trim());
    final year = int.tryParse(_yearController.text.trim());

    if (!RegExp(r'^\d{4}$').hasMatch(last4)) {
      setState(() => _formError = 'Los últimos 4 dígitos deben ser exactamente 4 números');
      return;
    }
    if (month == null || month < 1 || month > 12) {
      setState(() => _formError = 'El mes de expiración no es válido');
      return;
    }
    if (year == null || year < 2026) {
      setState(() => _formError = 'El año de expiración no es válido');
      return;
    }
    setState(() => _formError = null);

    final provider = context.read<PaymentMethodProvider>();
    final success = await provider.createPaymentMethod(
      type: 'CARD',
      name: _nameController.text.trim(),
      lastFourDigits: last4,
      expirationMonth: month,
      expirationYear: year,
    );

    if (!mounted) return;
    if (success) {
      _closeCardForm();
    } else {
      setState(() => _formError = provider.errorMessage ?? 'No se pudo agregar la tarjeta');
    }
  }

  Future<void> _handleAddCash() async {
    final provider = context.read<PaymentMethodProvider>();
    final success = await provider.createPaymentMethod(type: 'CASH', name: 'Efectivo');
    if (!mounted || success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(provider.errorMessage ?? 'No se pudo agregar')),
    );
  }

  Future<void> _handleAddOther(String provider, String type) async {
    final paymentProvider = context.read<PaymentMethodProvider>();
    final success = await paymentProvider.createPaymentMethod(type: type, provider: provider, name: provider);
    if (!mounted || success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(paymentProvider.errorMessage ?? 'No se pudo agregar $provider')),
    );
  }

  Future<void> _handleDelete(String id) async {
    final provider = context.read<PaymentMethodProvider>();
    final success = await provider.deletePaymentMethod(id);
    if (!mounted || success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(provider.errorMessage ?? 'No se pudo eliminar')),
    );
  }

  Future<void> _handleSetDefault(String id) async {
    final provider = context.read<PaymentMethodProvider>();
    final success = await provider.setDefaultPaymentMethod(id);
    if (!mounted || success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(provider.errorMessage ?? 'No se pudo actualizar')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryBrown = AppColors.primary;
    final paymentProvider = context.watch<PaymentMethodProvider>();
    final hasCash = paymentProvider.methods.any((m) => m.type == 'CASH');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          ProfileSubPageHeader(
            title: 'Métodos de Pago',
            subtitle: 'Gestiona tus formas de pago preferidas',
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: paymentProvider.fetchPaymentMethods,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SavedPaymentMethodsSection(
                      methods: paymentProvider.methods,
                      isLoading: paymentProvider.isLoading,
                      onSetDefault: _handleSetDefault,
                      onDelete: _handleDelete,
                    ),
                    const SizedBox(height: 12),
                    if (!_showCardForm)
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryBrown,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                onPressed: () => setState(() => _showCardForm = true),
                                icon: const Icon(Icons.add),
                                label: const Text('Agregar Tarjeta',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                          if (!hasCash) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: theme.colorScheme.onSurface,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  onPressed: _handleAddCash,
                                  icon: const Icon(Icons.attach_money_rounded, size: 18),
                                  label: const Text('Efectivo',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    if (_showCardForm) ...[
                      PaymentMethodFormCard(
                        primaryBrown: primaryBrown,
                        nameController: _nameController,
                        last4Controller: _last4Controller,
                        monthController: _monthController,
                        yearController: _yearController,
                        isSaving: paymentProvider.isSubmitting,
                        errorText: _formError,
                        onClose: _closeCardForm,
                        onSave: _saveCard,
                      ),
                    ],
                    const SizedBox(height: 24),
                    OtherPaymentOptionsSection(
                      methods: paymentProvider.methods,
                      onAdd: _handleAddOther,
                    ),
                    const SizedBox(height: 16),
                    const SecurePaymentInfoCard(),
                    const SizedBox(height: 24),
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
