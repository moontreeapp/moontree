import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/presentation/services/services.dart' as services;
import 'package:client_front/presentation/components/components.dart'
    as components;

class SystemBackButton {
  static const MethodChannel backButtonChannel =
      MethodChannel('backButtonChannel');
  static const MethodChannel sendToBackChannel =
      MethodChannel('sendToBackChannel');
  const SystemBackButton();

  /// our override to activate our custom back functionality
  Future<void> backButtonPressed() async {
    if (Platform.isAndroid &&
        ['/', '/login/create', '/wallet/holdings']
            .contains(streams.app.path.value)) {
      // edgecase: if at home screen, minimize app
      sendToBackChannel.invokeMethod('sendToBackground');
    } else if (services.screenflags.active) {
      // deactivate the back button in these edge cases...
      // if loading sheet is up do nothing
      // if system dialogue box is up navigator pop
      // if full bottom sheet is up navigator pop
      // if custom bottom modalsheet always in front is up navigator pop
      // instead of pop we should do nothing. the context isn't available and
      // some of these we want to do nothing anyway.
      print('back button disabled in this case');
    } else {
      await services.sailor.goBack();
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
