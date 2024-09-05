import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:magic/services/services.dart' as services;
import 'package:magic/utils/log.dart';
//import 'package:magic/presentation/services/services.dart' show sail;

class SystemBackButton {
  static const MethodChannel backButtonChannel =
      MethodChannel('backButtonChannel');
  static const MethodChannel sendToBackChannel =
      MethodChannel('sendToBackChannel');

  SystemBackButton();
  Function? function;
  List<Function> functions = [];

  /// our override to activate our custom back functionality
  Future<void> backButtonPressed() async {
    if (Platform.isAndroid) {
      if (function != null) {
        return function!();
      } else if (services.screenflags.active) {
        // deactivate the back button in these edge cases...
        // if loading sheet is up do nothing
        // if system dialogue box is up navigator pop
        // if full bottom sheet is up navigator pop
        // if custom bottom modalsheet always in front is up navigator pop
        // instead of pop we should do nothing. the context isn't available and
        // some of these we want to do nothing anyway.
        see('back button disabled in this case');
      } else {
        //await services.sail.back();
        sendToBackChannel.invokeMethod('sendToBackground');
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

  void setFunction(Function? fn) => function = fn;
  void setNextFunction(Function fn) => functions.add(fn);
  void useNextFunction() =>
      (functions.isNotEmpty ? functions.removeLast() : null)?.call();
  void discardFunctions(int count) =>
      functions = functions.sublist(0, max(0, functions.length - count));

  // shorthand
  void push(Function fn) => setNextFunction(fn);
  void pop() => useNextFunction();
}


// if you use a global key on a widget that has a controller:
// globalKey.currentState._controller.forward();
// we were going to use this solution but instead we just set the function.
