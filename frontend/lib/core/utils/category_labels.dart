/// Nombre de categoría tal como se muestra en la app (en español).
///
/// Los nombres de categoría viven en la base de datos y varios están
/// guardados en inglés ("Hot Drinks", "Desserts"...). Aquí se traducen
/// solo para mostrarlos: el dato guardado no cambia, así que filtros,
/// formularios y pedidos siguen usando el mismo id.
///
/// Si el nombre no está en la tabla (por ejemplo ya está en español, o
/// es una categoría nueva), se muestra tal cual.
String categoryLabel(String? name) {
  final original = (name ?? '').trim();
  if (original.isEmpty) return original;

  final key = _normalize(original);
  return _translations[key] ?? original;
}

String _normalize(String value) => value
    .toLowerCase()
    .replaceAll('&', ' and ')
    .replaceAll(RegExp(r'[-_/]+'), ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

const Map<String, String> _translations = {
  // Bebidas
  'drinks': 'Bebidas',
  'beverages': 'Bebidas',
  'hot drinks': 'Bebidas calientes',
  'hot beverages': 'Bebidas calientes',
  'hot': 'Calientes',
  'cold drinks': 'Bebidas frías',
  'cold beverages': 'Bebidas frías',
  'iced drinks': 'Bebidas frías',
  'cold': 'Frías',
  'iced': 'Frías',

  // Café y té
  'coffee': 'Café',
  'coffees': 'Cafés',
  'hot coffee': 'Café caliente',
  'hot coffees': 'Cafés calientes',
  'iced coffee': 'Café frío',
  'iced coffees': 'Cafés fríos',
  'cold coffee': 'Café frío',
  'cold brew': 'Café frío',
  'espresso': 'Espresso',
  'tea': 'Té',
  'teas': 'Tés',
  'hot tea': 'Té caliente',
  'iced tea': 'Té frío',
  'chocolate': 'Chocolate',
  'hot chocolate': 'Chocolate caliente',

  // Frías / especiales
  'frappe': 'Frappés',
  'frappes': 'Frappés',
  'frappuccino': 'Frappés',
  'frappuccinos': 'Frappés',
  'smoothies': 'Batidos',
  'smoothie': 'Batidos',
  'shakes': 'Malteadas',
  'milkshakes': 'Malteadas',
  'juices': 'Jugos',
  'juice': 'Jugos',
  'lemonades': 'Limonadas',
  'sodas': 'Gaseosas',
  'water': 'Agua',
  'specialty drinks': 'Bebidas especiales',
  'specialty': 'Especiales',
  'specials': 'Especiales',
  'seasonal': 'De temporada',

  // Postres y comida
  'desserts': 'Postres',
  'dessert': 'Postres',
  'sweets': 'Dulces',
  'cakes': 'Tortas',
  'cake': 'Tortas',
  'cheesecake': 'Cheesecake',
  'cheesecakes': 'Cheesecakes',
  'pastries': 'Pastelería',
  'pastry': 'Pastelería',
  'bakery': 'Panadería',
  'bread': 'Pan',
  'cookies': 'Galletas',
  'brownies': 'Brownies',
  'ice cream': 'Helados',
  'ice creams': 'Helados',
  'snacks': 'Snacks',
  'snack': 'Snacks',
  'food': 'Comida',
  'foods': 'Comida',
  'breakfast': 'Desayunos',
  'lunch': 'Almuerzos',
  'brunch': 'Brunch',
  'sandwiches': 'Sándwiches',
  'sandwich': 'Sándwiches',
  'salads': 'Ensaladas',
  'sides': 'Acompañamientos',
  'combos': 'Combos',
  'combo': 'Combos',
  'extras': 'Extras',
  'add ons': 'Adicionales',
  'addons': 'Adicionales',
  'other': 'Otros',
  'others': 'Otros',
  'merch': 'Mercancía',
  'merchandise': 'Mercancía',
};
