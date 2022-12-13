/// https://docs.flutter.dev/testing/integration-tests#android-setup
/// https://github.com/flutter/flutter/tree/main/packages/integration_test#android-device-testing
package com.moontree.mobile;

import androidx.test.rule.ActivityTestRule;
import dev.flutter.plugins.integration_test.FlutterTestRunner;
import org.junit.Rule;
import org.junit.runner.RunWith;

@RunWith(FlutterTestRunner.class)
public class MainActivityTest {
  @Rule
  public ActivityTestRule<MainActivity> rule = new ActivityTestRule<>(MainActivity.class, true, false);
}