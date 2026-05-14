import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('El entorno de pruebas de Flutter funciona', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('MERCADONA'),
        ),
      ),
    );

    expect(find.text('MERCADONA'), findsOneWidget);
  });
}
