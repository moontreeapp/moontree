import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:raven_mobile/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('first test', () {
    testWidgets('tap on accounts hamburger menu', (WidgetTester tester) async {
      app.main();

      await tester.pumpAndSettle();

      // Verify the "Receive / Send" buttons exist
      expect(find.text('Send'), findsOneWidget);
      expect(find.text('Settings'), findsNothing);

      final Finder button = find.byIcon(Icons.more_vert);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
    });
  });
}
