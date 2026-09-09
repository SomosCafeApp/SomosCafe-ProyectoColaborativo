import 'package:flutter/material.dart';
import '../components/payment_methods_header.dart';
import '../components/saved_payment_methods_section.dart';
import '../components/other_payment_options_section.dart';
import '../components/secure_payment_info_card.dart';

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
    final primaryBrown = theme.colorScheme.primary;
    final bgCanvas = theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgCanvas,
      body: Column(
        children: [
          PaymentMethodsHeader(primaryBrown: primaryBrown),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
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
                    primaryBrown: primaryBrown,
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