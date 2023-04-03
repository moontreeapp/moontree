// https://docs.flutter.dev/testing/integration-tests
// run with flutter in browser:
// flutter test integration_test/examples/test_testing.dart -d emulator-5554
// run on andorid emulator:
// C:\moontree\moontreeV1\client_front\android>gradlew app:connectedAndroidTest -Ptarget=`pwd`/../integration_test/examples/test_testing.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized(); // NEW

  testWidgets('passing test example', (tester) async {
    expect(2 + 2, equals(4));
  });

  testWidgets('failing test example', (tester) async {
    expect(2 + 2, equals(5));
  });
}
