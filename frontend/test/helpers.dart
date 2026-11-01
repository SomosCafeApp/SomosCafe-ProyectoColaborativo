import 'package:somoscafeapp/models/drink_options.dart';
import 'package:somoscafeapp/models/product_model.dart';

/// Opciones iguales a las que manda el backend (GET /customization/options).
DrinkOptions testOptions() => DrinkOptions.fromJson({
      'sizes': {'Pequeño': -2500, 'Mediano': 0, 'Grande': 5000},
      'types': ['Caliente', 'Frío'],
      'milks': {'Entera': 0, 'Deslactosada': 0, 'Avena': 1000, 'Almendra': 1500, 'Soya': 1000},
      'extraShot': {'price': 3000, 'max': 3},
      'toppings': {
        'Crema batida': 2000,
        'Canela': 1000,
        'Chispas': 2500,
        'Caramelo': 1500,
        'Cacao en polvo': 1000,
        'Virutas de chocolate': 2000,
        'Malvaviscos': 1800,
      },
      'toppingRules': {
        'extraPortionPrice': 300,
        'maxQuantity': 4,
        'compatibility': {
          'Malvaviscos': {'types': ['Caliente']},
        },
      },
      'syrups': {'prices': {'Vainilla': 1500}, 'max': 2},
      'sweeteners': {'prices': {'Azúcar': 0}, 'max': 3},
      'latteArt': {'keywords': ['latte', 'capuchino'], 'designs': ['Corazón', 'Hoja', 'Cisne', 'Tulipán', 'Rosetta', 'Estrella']},
      'coffeeKeywords': ['latte', 'capuchino', 'café'],
      'sizeOunces': {'Pequeño': 8, 'Mediano': 12, 'Grande': 16},
      'defaults': {'size': 'Mediano', 'type': 'Caliente', 'milk': 'Entera'},
    });

Product testLatte({double price = 8000}) => Product(
      id: 'p-latte',
      name: 'Latte',
      description: 'Café con leche',
      price: price,
      categoryName: 'Cafés calientes',
    );
