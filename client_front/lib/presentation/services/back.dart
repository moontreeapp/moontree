import 'dart:io';
import 'package:flutter/services.dart';
import 'package:client_front/presentation/services/services.dart' as services;
import 'package:client_front/presentation/services/services.dart' show sail;

class SystemBackButton {
  static const MethodChannel backButtonChannel =
      MethodChannel('backButtonChannel');
  static const MethodChannel sendToBackChannel =
      MethodChannel('sendToBackChannel');
  const SystemBackButton();

  /// our override to activate our custom back functionality
  Future<void> backButtonPressed() async {
    if (Platform.isAndroid) {
      if ([
        '/',
        '/login/create',
        '/login/native',
        '/login/password',
        '/wallet/holdings',
      ].contains(sail.latestLocation)) {
        // edgecase: if at home screen, minimize app
        sendToBackChannel.invokeMethod('sendToBackground');
      } else if (services.screenflags.active ||
          ['/backup/intro'].contains(sail.latestLocation)) {
        // deactivate the back button in these edge cases...
        // if loading sheet is up do nothing
        // if system dialogue box is up navigator pop
        // if full bottom sheet is up navigator pop
        // if custom bottom modalsheet always in front is up navigator pop
        // instead of pop we should do nothing. the context isn't available and
        // some of these we want to do nothing anyway.
        print('back button disabled in this case');
      } else {
        await services.sail.back();
      }
    }
  }

  void initListener() {
    backButtonChannel.setMethodCallHandler((call) async {
      if (call.method == "backButtonPressed") {
        return backButtonPressed();
      }
    });
  }
}
