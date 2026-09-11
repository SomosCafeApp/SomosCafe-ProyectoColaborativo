class ProductCustomization {
  final String size;
  final String type;
  final String milk;
  final String sugar;
  final int extraShots;
  final Set<String> toppings;

  ProductCustomization({
    required this.size,
    required this.type,
    required this.milk,
    required this.sugar,
    required this.extraShots,
    required this.toppings,
  });

  double calculateTotalPrice(double basePrice, int quantity) {
    double extraCost = 0.0;

    if (size == 'Pequeño') extraCost += 3000;
    if (size == 'Grande') extraCost += 5000;

    if (milk == 'Almendra' || milk == 'Avena') extraCost += 1000;
    if (milk == 'Soya') extraCost += 2000;

    extraCost += extraShots * 2000;

    for (var topping in toppings) {
      switch (topping) {
        case 'Crema batida':
          extraCost += 2000;
          break;
        case 'Canela':
          extraCost += 1000;
          break;
        case 'Chispas chocolate':
          extraCost += 2500;
          break;
        case 'Caramelo':
          extraCost += 1500;
          break;
      }
    }

    return (basePrice + extraCost) * quantity;
  }
}