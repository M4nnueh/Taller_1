import 'package:flutter_test/flutter_test.dart';
import 'package:async_workshop_app/main.dart';

void main() {
  testWidgets('Carga el menú principal correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const AsyncWorkshopApp());

    expect(find.text('Taller 2: Concurrencia & Segundo Plano'), findsOneWidget);
    expect(find.text('1. Future & async/await'), findsOneWidget);
    expect(find.text('2. Timer (Cronómetro)'), findsOneWidget);
    expect(find.text('3. Isolate (Tarea Pesada)'), findsOneWidget);
  });
}
