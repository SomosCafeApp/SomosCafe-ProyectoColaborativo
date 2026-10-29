import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/product_provider.dart';
import '../widgets/profile/profile_sub_page_header.dart';
import 'product_detail_page.dart';

/// Datos de una promoción vigente para el cliente
/// (GET /api/promotions/available/:id).
class PromotionInfo {
  final String id;
  final String name;
  final String description;
  final bool isPercentage;
  final double discountValue;
  final double minimumPurchase;
  final DateTime endDate;
  final List<PromotionInfoProduct> products;

  const PromotionInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.isPercentage,
    required this.discountValue,
    required this.minimumPurchase,
    required this.endDate,
    required this.products,
  });

  factory PromotionInfo.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'];
    return PromotionInfo(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isPercentage: json['discountType'] != 'fixed',
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0,
      minimumPurchase: (json['minimumPurchase'] as num?)?.toDouble() ?? 0,
      endDate: DateTime.tryParse(json['endDate'] as String? ?? '')?.toLocal() ?? DateTime.now(),
      products: rawProducts is List
          ? rawProducts
              .whereType<Map<String, dynamic>>()
              .map(PromotionInfoProduct.fromJson)
              .toList()
          : const [],
    );
  }

  static String _money(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');

  String get benefit =>
      isPercentage ? '${discountValue.toStringAsFixed(discountValue % 1 == 0 ? 0 : 1)}% de descuento' : '\$${_money(discountValue)} de descuento';

  String get validUntil {
    final d = endDate.day.toString().padLeft(2, '0');
    final m = endDate.month.toString().padLeft(2, '0');
    return 'Vigente hasta el $d/$m/${endDate.year}';
  }

  String get minimumText => minimumPurchase > 0 ? 'En compras desde \$${_money(minimumPurchase)}' : '';
}

class PromotionInfoProduct {
  final String id;
  final String name;
  final double price;
  final String image;

  const PromotionInfoProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
  });

  factory PromotionInfoProduct.fromJson(Map<String, dynamic> json) => PromotionInfoProduct(
        id: (json['id'] ?? json['_id'] ?? '').toString(),
        name: json['name'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        image: json['image'] as String? ?? '',
      );
}

/// Detalle de una promoción: beneficio, vigencia, condiciones y los
/// productos incluidos (cada uno abre su ficha).
class PromotionDetailPage extends StatelessWidget {
  final PromotionInfo promotion;

  const PromotionDetailPage({super.key, required this.promotion});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final card = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final products = context.read<ProductProvider>().products;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const ProfileSubPageHeader(title: 'Promoción', subtitle: 'Aprovecha este beneficio'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(promotion.name,
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      Text(promotion.benefit,
                          style: const TextStyle(color: AppColors.accentYellow, fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text(promotion.validUntil, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      if (promotion.minimumText.isNotEmpty)
                        Text(promotion.minimumText, style: const TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
                if (promotion.description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(promotion.description, style: TextStyle(color: subColor, fontSize: 15, height: 1.4)),
                ],
                if (promotion.products.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text('Productos incluidos',
                      style: TextStyle(color: textColor, fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  ...promotion.products.map((p) {
                    final match = products.where((x) => x.id == p.id);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        minVerticalPadding: 12,
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 52,
                            height: 52,
                            child: p.image.startsWith('http')
                                ? Image.network(p.image, fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const Icon(Icons.local_cafe_rounded))
                                : const Icon(Icons.local_cafe_rounded),
                          ),
                        ),
                        title: Text(p.name, style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
                        subtitle: Text('\$${PromotionInfo._money(p.price)}', style: TextStyle(color: subColor)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: match.isEmpty
                            ? null
                            : () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => ProductDetailPage(product: match.first)),
                                ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
