import 'package:flutter/material.dart';
import '../../../data/models/product.dart';

class SearchResultItem extends StatelessWidget {
  final Product product;

  const SearchResultItem({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryBrown = theme.colorScheme.primary;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = textColor.withAlpha(150);

    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: primaryBrown.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.coffee, color: primaryBrown),
        ),
        title: Text(
          product.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor),
        ),
        subtitle: Text(
          product.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: subtitleColor),
        ),
        trailing: Text(
          '\$${product.price.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryBrown,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}