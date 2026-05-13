import 'package:flutter_test/flutter_test.dart';
import 'package:egm_project_app/main.dart';

void main() {
  testWidgets('La app carga la pantalla principal de Mercadona', (tester) async {
    await tester.pumpWidget(const MercadonaApp());
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('mercadona'), findsOneWidget);
    expect(find.text('Novedades'), findsOneWidget);
  });
}
