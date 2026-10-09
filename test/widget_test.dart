// Prueba de humo de la aplicación Simulador Ambiental.
//
// Verifica que la app arranca con su navegación principal. En el
// entorno de test no existe el plugin de sqflite, por lo que el
// Dashboard debe mostrar su mensaje de error sin cerrar la app.

import 'package:flutter_test/flutter_test.dart';

import 'package:simulador_ambiental/main.dart';

void main() {
  testWidgets('La app arranca con navegación y maneja el error de BD',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SimuladorAmbientalApp());
    await tester.pump(const Duration(seconds: 1));

    // Navegación inferior presente.
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Simulador'), findsOneWidget);
    expect(find.text('Historial'), findsOneWidget);

    // Título de la pantalla principal.
    expect(find.text('Simulador Ambiental'), findsOneWidget);

    // Sin plugin de SQLite en el test, debe verse el error controlado
    // (no un crash).
    expect(find.textContaining('No se pudo abrir la base de datos'),
        findsOneWidget);
  });
}
