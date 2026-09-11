import 'package:flutter/material.dart';
import 'product.dart';

class WelcomeData {
  static const List<Map<String, dynamic>> categories = [
    {
      'id': 'hot_coffee',
      'label': 'Cafés\nCalientes',
      'icon': Icons.coffee_rounded,
      'bgColor': Color(0xFFFEF3D6),
      'iconBgColor': Color(0xFFF7E2AD),
      'iconColor': Color(0xFF8C5C2B),
    },
    {
      'id': 'cold_drinks',
      'label': 'Bebidas\nFrías',
      'icon': Icons.ac_unit_rounded,
      'bgColor': Color(0xFFE1F5FE),
      'iconBgColor': Color(0xFFB3E5FC),
      'iconColor': Color(0xFF0288D1),
    },
    {
      'id': 'desserts',
      'label': 'Postres',
      'icon': Icons.cake_rounded,
      'bgColor': Color(0xFFFCE4EC),
      'iconBgColor': Color(0xFFF8BBD0),
      'iconColor': Color(0xFFC2185B),
    },
  ];

  static final List<Product> popularProducts = [
    Product(id: '1', name: 'Espresso', description: 'Intenso y aromático', price: 8000, imageUrl: ''),
    Product(id: '2', name: 'Cappuccino', description: 'Con espuma de leche sedosa', price: 12000, imageUrl: ''),
  ];

  static final List<Product> fullMenuProducts = [
    Product(id: '3', name: 'Espresso Doble', description: 'Doble carga de café', price: 9500, imageUrl: '', categoryId: 'hot_coffee'),
    Product(id: '4', name: 'Cappuccino', description: 'Con espuma de leche sedosa', price: 12000, imageUrl: '', categoryId: 'hot_coffee'),
    Product(id: '5', name: 'Cold Brew', description: 'Infusionado en frío', price: 11000, imageUrl: '', categoryId: 'cold_drinks'),
    Product(id: '6', name: 'Frappé Caramelo', description: 'Bebida helada con caramelo', price: 14000, imageUrl: '', categoryId: 'cold_drinks'),
    Product(id: '7', name: 'Cheesecake', description: 'Tarta con mermelada artesanal', price: 13000, imageUrl: '', categoryId: 'desserts'),
    Product(id: '8', name: 'Torta Chocolate', description: 'Bizcocho húmedo de cacao', price: 12500, imageUrl: '', categoryId: 'desserts'),
  ];
}