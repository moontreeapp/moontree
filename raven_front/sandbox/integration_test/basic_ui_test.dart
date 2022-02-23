// not relevant

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:raven_front/main.dart';

void main() {
  var binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
      as IntegrationTestWidgetsFlutterBinding;

  group('Basic UI', () {
    // testWidgets('settings page exists', (WidgetTester tester) async {
    //   app.main();

    //   await binding.convertFlutterSurfaceToImage();
    //   // await Future.delayed(Duration(seconds: 3));
    //   await tester.pumpAndSettle();
    //   await binding.takeScreenshot('screenshot-1');

    //   // Verify the "Receive / Send" buttons exist
    //   expect(find.text('Send'), findsOneWidget);
    //   expect(find.text('Settings'), findsNothing);

    //   final Finder button = find.byIcon(Icons.more_vert);
    //   await tester.tap(button);
    //   await tester.pumpAndSettle();
    //   expect(find.text('Settings'), findsOneWidget);
    // });

    testWidgets('send page exists', (WidgetTester tester) async {
      await binding.convertFlutterSurfaceToImage();

      await tester.pumpWidget(RavenMobileApp());

      await binding.takeScreenshot('screenshot-1');
      // Verify the "Receive / Send" buttons exist
      final Finder button = find.text('Send');
      expect(find.text('Send'), findsOneWidget);
      // expect(find.text('Settings'), findsNothing);

      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
    });
  });
}
