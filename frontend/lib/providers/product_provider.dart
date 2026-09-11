import '../models/product.dart';

class ProductData {
  static List<Product> getProducts() {
    return [
      Product(
        id: '1',
        name: 'Espresso Tradicional',
        description: 'Un shot intenso y concentrado con notas tostadas y crema consistente, preparado con granos de origen local.',
        price: 4500.0,
        imageUrl: '',
      ),
      Product(
        id: '2',
        name: 'Cappuccino de la Casa',
        description: 'Equilibrio perfecto entre espresso, leche vaporizada y una capa cremosa de espuma, decorado con cacao.',
        price: 7000.0,
        imageUrl: '',
      ),
      Product(
        id: '3',
        name: 'Latte Moca',
        description: 'Combinación suave de espresso, leche condensada, jarabe de chocolate dulce y toque de canela.',
        price: 8500.0,
        imageUrl: '',
      ),
    ];
  }
}