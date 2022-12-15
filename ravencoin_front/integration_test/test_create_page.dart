//cd ravencoin_front && flutter test integration_test/test_create_page.dart -d emulator-5554
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/main.dart' as app;
import 'package:ravencoin_front/services/dev.dart';
import 'package:ravencoin_front/services/lookup.dart';
import 'package:ravencoin_front/widgets/widgets.dart';
import 'package:wallet_utils/wallet_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('start the app', (WidgetTester tester) async {
      // todo: remove skipbackup and actually tap the words in order
      app.main([], [DevFlag.skipPin, DevFlag.skipBackup]);
      // splash screen
      await tester.pumpAndSettle(Duration(seconds: 30));
      // setup page
      await tester.pumpAndSettle();
      Finder target = find.widgetWithText(OutlinedButton, 'MOONTREE PASSWORD');
      expect(target, findsOneWidget);
      target = find.widgetWithText(OutlinedButton, 'ANDROID PHONE SECURITY');
      expect(target, findsOneWidget);
      await tester.tap(target);

      // security page
      await tester.pumpAndSettle();
      target = find.byType(Checkbox);
      expect(target, findsOneWidget);
      await tester.tap(target);
      await tester.pumpAndSettle();
      target = find.widgetWithText(OutlinedButton, 'CREATE WALLET');
      expect(target, findsOneWidget);
      await tester.tap(target);

      // pin page - skipped in dev
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 10));

      // backup intro page - skipped in dev
      //await tester.pumpAndSettle();
      //target = find.widgetWithText(OutlinedButton, 'BACKUP');
      //expect(target, findsOneWidget);
      //await tester.tap(target);
      //
      //// backup page
      //await tester.pumpAndSettle();
      //target = find.widgetWithText(OutlinedButton, 'VERIFY BACKUP');
      //expect(target, findsOneWidget);
      //await tester.tap(target);
      //
      //// backup verify page
      //await tester.pumpAndSettle();
      //target = find.text('Please tap your words in the correct order.');
      //expect(target, findsOneWidget);
      //await tester.doubleTap(target);

      // tutorial overlay
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 10));
      target = find.byType(TutorialLayer);
      expect(target, findsOneWidget);
      await tester.tap(target);

      // home page
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 10));
      target = find.byType(PageLead);
      expect(target, findsOneWidget);
      await tester.tap(target);

      // menu
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      target = find.widgetWithText(ListTile, 'Settings');
      expect(target, findsOneWidget);
      await tester.tap(target);

      // settings
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      target = find.widgetWithText(ListTile, 'Developer');
      expect(target, findsOneWidget);
      await tester.tap(target);

      // developer page
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      target = find.byType(Switch); //find.text('Developer Mode')
      expect(target, findsOneWidget);
      await tester.tap(target);
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      target = find.byType(PageLead);
      expect(target, findsOneWidget);
      await tester.tap(target);

      // settings
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 2));
      target = find.byType(PageLead);
      expect(target, findsOneWidget);
      await tester.tap(target);

      // menu
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 2));
      target = find.byType(PageLead);
      expect(target, findsOneWidget);
      await tester.tap(target);

      // home page
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 2));
      target = find.byType(ConnectionLight);
      expect(target, findsOneWidget);
      await tester.tap(target);

      // home page
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 2));
      target = find.widgetWithText(ListTile, 'Ravencoin testnet');
      expect(target, findsOneWidget);
      await tester.tap(target);

      // home page
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 10));
      target = find.text('IMPORT');
      expect(target, findsOneWidget);
      await tester.tap(target);

      // import page
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 10));
      await dotenv.load();
      final wallet = dotenv.env['TEST_WALLET_02'];
      //final jsonImport = dotenv.env['TEST_JSON_IMPORT'];
      //final jsonKey = dotenv.env['TEST_JSON_KEY'];
      target = find.byType(EditableText);
      expect(target, findsOneWidget);
      await tester.enterText(target, wallet!);
      target = find.widgetWithText(OutlinedButton, 'IMPORT');
      expect(target, findsOneWidget);
      await tester.tap(target);

      // importing
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 10));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 50));

      // home page
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 60));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      target = find.widgetWithText(OutlinedButton, 'SEND');
      expect(target, findsOneWidget);
      await tester.tap(target);

      // send page
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 2));
      // todo: choose asset
      //await tester.pumpAndSettle();
      //await Future.delayed(Duration(seconds: 2));
      //target = find.byKey(Key('sendAssetDropDown'));
      //expect(target, findsOneWidget);
      //await tester.press(target);
      //await tester.pumpAndSettle();
      //await Future.delayed(Duration(seconds: 2));
      //target = find.widgetWithText(ListTile, 'Ravencoin');
      //expect(target, findsOneWidget);
      //await tester.tap(target);
      // choose address
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 2));
      final String address = services.wallet.getEmptyAddress(
        Current.wallet,
        NodeExposure.external,
        address: null,
      );
      target = find.byKey(Key('sendAddress'), skipOffstage: false);
      expect(target, findsOneWidget);
      await tester.enterText(target, address);
      // choose amount
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 2));
      final double amount = satCoinRatio * randomInRange(1, satsPerCoin);
      target = find.byKey(Key('sendAmount'), skipOffstage: false);
      expect(target, findsOneWidget);
      await tester.enterText(target, amount.toString());
      // choose note
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 2));
      target = find.byKey(Key('sendNote'), skipOffstage: false);
      expect(target, findsOneWidget);
      await tester.enterText(target, 'automated testing');
      //await tester.sendKeyEvent(LogicalKeyboardKey.enter); // does not dismiss
      //target = find.byType(Coin); // does not dismiss
      //expect(target, findsOneWidget);
      //await tester.tap(target);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      // press preview
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 2));
      target = find.widgetWithText(OutlinedButton, 'PREVIEW');
      expect(target, findsOneWidget);
      await tester.tap(target);
      // checkout page
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 10));
      // grab total amount
      target = find.byKey(Key('checkoutTotal'));
      expect(target, findsOneWidget);
      final String? total =
          (target.first.evaluate().single.widget as Text).data;
      expect(total, isNotNull);
      print(total);
      target = find.widgetWithText(OutlinedButton, 'SEND');
      expect(target, findsOneWidget);
      await tester.tap(target);
      // home page
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 10));
      target = find.text('Ravencoin');
      //find.widgetWithText(FittedBox, 'Ravencoin')
      expect(target, findsOneWidget);
      await tester.tap(target);

      // transaction list page
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 10));
      target = find.text(total!);
      //find.widgetWithText(FittedBox, 'Ravencoin')
      expect(target, findsOneWidget);
      await tester.tap(target);

      // LAST PAGE
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 10));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 50));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 60 * 5));
      //find.byType(AppBarScrim)
      //find.text('Next')
      //find.byType(PhysicalModel) //dismiss dialogue
    });
  });
}

extension TapTapExt on WidgetTester {
  Future<void> doubleTap(Finder finder) async {
    await tap(finder);
    await Future.delayed(Duration(milliseconds: 10));
    await tap(finder);
    await Future.delayed(Duration(milliseconds: 100));
    await tap(finder);
    await Future.delayed(Duration(milliseconds: 10));
    await tap(finder);
  }
}
/* success example results
PS C:\moontree\moontreeV1\ravencoin_front> flutter test integration_test/examples/test_an_app.dart -d emulator-5554
00:00 +0: ... C:\moontree\moontreeV1\ravencoin_front\integration_test\examples\test_an_app.dart           R00:47 +0: ... C:\moontree\moontreeV1\ravencoin_front\integration_test\examples\test_an_app.dart      47.4s 
√  Built build\app\outputs\flutter-apk\app-debug.apk.
00:49 +0: ... C:\moontree\moontreeV1\ravencoin_front\integration_test\examples\test_an_app.dart           I00:52 +0: ... C:\moontree\moontreeV1\ravencoin_front\integration_test\examples\test_an_app.dart    2,462ms 
01:01 +1: All tests passed!
*/

/* fail example results
...
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════       
The following TestFailure was thrown running a test:
Expected: exactly one matching node in the widget tree
  Actual: _TextFinder:<zero widgets with text "0" (ignoring offstage widgets)>
   Which: means none were found but one was expected

When the exception was thrown, this was the stack:
#4      main.<anonymous closure>.<anonymous closure> (file:///C:/moontree/moontreeV1/ravencoin_front/integration_test/examples/test_an_app.dart:24:7)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///C:/moontree/moontreeV1/ravencoin_front/integration_test/examples/test_an_app.dart line 24        
The test description was:
  tap on the floating action button, verify counter
════════════════════════════════════════════════════════════════════════════════════════════════════       
01:11 +0 -1: end-to-end test tap on the floating action button, verify counter [E]
  Test failed. See exception logs above.
  The test description was: tap on the floating action button, verify counter


To run this test again: C:\flutter\bin\cache\dart-sdk\bin\dart.exe test C:\moontree\moontreeV1\ravencoin_front\integration_test\examples\test_an_app.dart -p vm --plain-name 'end-to-end test tap on the floating action button, verify counter'
01:12 +0 -1: Some tests failed.
*/
