import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_project/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Sorty(initialScreen: Scaffold(body: Text('Lung Lens Test'))),
    );

    expect(find.text('Lung Lens Test'), findsOneWidget);
  });
}
