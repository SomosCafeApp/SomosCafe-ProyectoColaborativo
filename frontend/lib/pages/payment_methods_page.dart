import 'package:flutter/material.dart';

import '../widgets/profile/profile_sub_page_header.dart';
import '../widgets/payment_methods/saved_payment_methods_section.dart';
import '../widgets/payment_methods/other_payment_options_section.dart';
import '../widgets/payment_methods/secure_payment_info_card.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  String _defaultMethod = 'card';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          ProfileSubPageHeader(
            title: 'Métodos de Pago',
            subtitle: 'Gestiona tus formas de pago preferidas',
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SavedPaymentMethodsSection(
                    defaultMethod: _defaultMethod,
                    onSetDefault: (method) {
                      setState(() {
                        _defaultMethod = method;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  const OtherPaymentOptionsSection(),

                  const SizedBox(height: 16),

                  const SecurePaymentInfoCard(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}