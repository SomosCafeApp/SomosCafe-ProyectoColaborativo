import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:somoscafeapp/animations/animations.dart';
import 'package:somoscafeapp/widgets/common/state_view.dart';

void main() {
  testWidgets('BrandRefresh ejecuta una actualización real y oculta el indicador', (tester) async {
    var calls = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BrandRefresh(
          minVisible: const Duration(milliseconds: 100),
          onRefresh: () async {
            calls++;
            await Future<void>.delayed(const Duration(milliseconds: 50));
          },
          child: ListView(children: [for (var i = 0; i < 30; i++) SizedBox(height: 60, child: Text('fila $i'))]),
        ),
      ),
    ));

    // En la carga inicial no hay ningún indicador.
    expect(find.byType(CoffeeCupLoader), findsNothing);

    await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(calls, 1);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(CoffeeCupLoader), findsNothing);
  });

  testWidgets('el indicador de taza tiene etiqueta accesible', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: CoffeeCupLoader())));
    expect(find.bySemanticsLabel('Cargando'), findsOneWidget);
  });

  testWidgets('StateView muestra título, mensaje y acción', (tester) async {
    var taps = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: StateView(kind: StateKind.offline, actionLabel: 'Reintentar', onAction: () => taps++)),
    ));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Sin conexión'), findsOneWidget);
    await tester.tap(find.text('Reintentar'));
    expect(taps, 1);
  });

  test('StateView distingue falta de conexión de otros errores', () {
    expect(StateView.kindForError('Error de conexión con el servidor'), StateKind.offline);
    expect(StateView.kindForError('Producto no encontrado'), StateKind.error);
  });
}
