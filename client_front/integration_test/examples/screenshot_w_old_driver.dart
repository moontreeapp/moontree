import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await integrationDriver(
    onScreenshot: (String screenshotName, List<int> screenshotBytes,
        [Map<String, Object?>? _]) async {
      final File image = File('$screenshotName.png');
      image.writeAsBytesSync(screenshotBytes);
      // Return false if the screenshot is invalid.
      return true;
    },
  );
}
/* does not work:
C:\moontree\moontreeV1\client_front\android>gradlew app:connectedAndroidTest -Ptarget=`pwd`/../test/integration/test_driver/integration_test.dart

> Configure project :file_picker
WARNING: The option setting 'android.enableR8=true' is deprecated.
It will be removed in version 5.0 of the Android Gradle plugin.
You will no longer be able to disable R8

> Task :app:connectedDebugAndroidTest
Starting 0 tests on Pixel_3a_API_30(AVD) - 11

com.android.build.gradle.internal.testing.ConnectedDevice > No tests found.[Pixel_3a_API_30(AVD) - 11] FAILED DLE
No tests found. This usually means that your test classes are not in the form that your test runner expects (e.g. don't inherit from TestCase or lack @Test annotations).

> Task :app:connectedDebugAndroidTest FAILED

FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:connectedDebugAndroidTest'.
> There were failing tests. See the report at: file:///C:/moontree/moontreeV1/client_front/build/app/reports/androidTests/connected/flavors/debugAndroidTest/index.html

* Try:
Run with --stacktrace option to get the stack trace. Run with --info or --debug option to get more log output. Run with --scan to get full insights.

* Get more help at https://help.gradle.org

Deprecated Gradle features were used in this build, making it incompatible with Gradle 7.0.
Use '--warning-mode all' to show the individual deprecation warnings.
See https://docs.gradle.org/6.7/userguide/command_line_interface.html#sec:command_line_warnings

BUILD FAILED in 53s
368 actionable tasks: 7 executed, 361 up-to-date
*/