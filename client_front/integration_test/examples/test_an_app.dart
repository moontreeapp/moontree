import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import './an_app.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('tap on the floating action button, verify counter',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      // Verifies that the counter starts at 0.
      expect(find.text('0'), findsOneWidget);
      // Finds the floating action button to tap on.
      final Finder fab = find.byTooltip('Increment');
      // Emulates a tap on the floating action button.
      await tester.tap(fab);
      // Triggers a frame.
      await tester.pumpAndSettle();
      // Verifies if the counter increments by 1.
      expect(find.text('1'), findsOneWidget);
      // fail example
      //expect(find.text('0'), findsOneWidget);
    });
  });
}
/* success example results
PS C:\moontree\moontreeV1\client_front> flutter test integration_test/examples/test_an_app.dart -d emulator-5554
00:00 +0: ... C:\moontree\moontreeV1\client_front\integration_test\examples\test_an_app.dart           R00:47 +0: ... C:\moontree\moontreeV1\client_front\integration_test\examples\test_an_app.dart      47.4s 
√  Built build\app\outputs\flutter-apk\app-debug.apk.
00:49 +0: ... C:\moontree\moontreeV1\client_front\integration_test\examples\test_an_app.dart           I00:52 +0: ... C:\moontree\moontreeV1\client_front\integration_test\examples\test_an_app.dart    2,462ms 
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
#4      main.<anonymous closure>.<anonymous closure> (file:///C:/moontree/moontreeV1/client_front/integration_test/examples/test_an_app.dart:24:7)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///C:/moontree/moontreeV1/client_front/integration_test/examples/test_an_app.dart line 24        
The test description was:
  tap on the floating action button, verify counter
════════════════════════════════════════════════════════════════════════════════════════════════════       
01:11 +0 -1: end-to-end test tap on the floating action button, verify counter [E]
  Test failed. See exception logs above.
  The test description was: tap on the floating action button, verify counter


To run this test again: C:\flutter\bin\cache\dart-sdk\bin\dart.exe test C:\moontree\moontreeV1\client_front\integration_test\examples\test_an_app.dart -p vm --plain-name 'end-to-end test tap on the floating action button, verify counter'
01:12 +0 -1: Some tests failed.
*/