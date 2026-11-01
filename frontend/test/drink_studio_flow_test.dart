import 'package:flutter_test/flutter_test.dart';
import 'package:somoscafeapp/models/drink_studio_stage.dart';
import 'package:somoscafeapp/providers/drink_studio_provider.dart';

import 'helpers.dart';

DrinkStudioProvider ready() {
  final s = DrinkStudioProvider.latte();
  s.debugLoad(testOptions(), latte: testLatte());
  return s;
}

void main() {
  test('las etapas siguen el orden pedido y terminan en el resultado', () {
    final s = ready();
    expect(s.step, StudioStep.temperature);
    expect(s.steps, [
      StudioStep.temperature,
      StudioStep.base,
      StudioStep.milk,
      StudioStep.art,
      StudioStep.toppings,
      StudioStep.result,
    ]);
  });

  test('en frío el arte latte desaparece del recorrido y vuelve en caliente', () {
    final s = ready();
    s.setType('Frío');
    expect(s.steps.contains(StudioStep.art), isFalse);
    s.setType('Caliente');
    expect(s.steps.contains(StudioStep.art), isTrue);
  });

  test('sin leche no hay arte latte (no hay sobre qué dibujar)', () {
    final s = ready();
    expect(s.canLatteArt, isTrue);
    s.changeMilk(-1);
    expect(s.hasMilk, isFalse);
    expect(s.canLatteArt, isFalse);
    expect(s.steps.contains(StudioStep.art), isFalse);
  });

  test('cambiar entre frío y caliente varias veces no pierde las selecciones', () {
    final s = ready();
    s.setSize('Grande');
    s.setMilk('Avena');
    s.toggleTopping('Canela');
    for (var i = 0; i < 6; i++) {
      s.setType(i.isEven ? 'Frío' : 'Caliente');
    }
    expect(s.size, 'Grande');
    expect(s.milk, 'Avena');
    expect(s.toppings, contains('Canela'));
  });

  test('los malvaviscos no se ofrecen en frío', () {
    final s = ready();
    expect(s.availableToppings.keys, contains('Malvaviscos'));
    s.setType('Frío');
    expect(s.availableToppings.keys, isNot(contains('Malvaviscos')));
  });

  test('se puede regresar a una etapa anterior sin perder lo elegido', () {
    final s = ready();
    s.setSize('Grande');
    s.next();
    s.next();
    s.setMilk('Almendra');
    s.goToStep(StudioStep.base);
    expect(s.step, StudioStep.base);
    expect(s.size, 'Grande');
    expect(s.milk, 'Almendra');
  });

  test('el precio sale de las reglas del menú, no de la interfaz', () {
    final s = ready();
    s.setSize('Grande'); // +5000
    s.setMilk('Avena'); // +1000
    s.toggleTopping('Canela'); // +1000
    expect(s.unitPrice, 8000 + 5000 + 1000 + 1000);
    s.quantity = 2;
    expect(s.drinkTotal, 2 * 15000);
  });

  test('sin latte real en el menú no se puede comprar', () {
    final s = ready();
    expect(s.canBuy, isTrue);
    final sinProducto = DrinkStudioProvider.latte();
    expect(sinProducto.canBuy, isFalse);
  });

  test('reiniciar vuelve a la primera etapa y limpia la compra', () {
    final s = ready();
    s.setSize('Grande');
    s.next();
    s.restart();
    expect(s.step, StudioStep.temperature);
    expect(s.size, 'Mediano');
  });

  test('el borrador conserva la bebida y se puede retomar', () {
    final s = ready();
    s.setSize('Grande');
    s.setMilk('Soya');
    s.toggleTopping('Caramelo');
    final draft = s.draftJson();

    final otra = ready();
    otra.resumeDraft(draft);
    expect(otra.size, 'Grande');
    expect(otra.milk, 'Soya');
    expect(otra.toppings, contains('Caramelo'));
  });
}
