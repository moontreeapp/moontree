import 'dart:async';

import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter/material.dart';
import 'package:raven_front/components/components.dart';

class KeyboardHidesWidget extends StatefulWidget {
  final Widget child;

  /// As default, view hide when keyboard opened.
  /// Set reversed = true, it'll reverse the logic.
  final bool reversed;

  /// if you want hide view but keep the layout, set keepView = true as default
  /// otherwise a view will dispose when keyboard opened
  /// Both mode support touch through below widget as well
  final bool keepView;

  const KeyboardHidesWidget(
      {Key? key,
      required this.child,
      this.reversed = false,
      this.keepView = true})
      : super(key: key);

  @override
  _KeyboardStateHidesWidget createState() => _KeyboardStateHidesWidget();
}

class _KeyboardStateHidesWidget extends State<KeyboardHidesWidget> {
  //late StreamSubscription<bool> keyboardSubscription;
  //
  //@override
  //void initState() {
  //  super.initState();
  //  var keyboardVisibilityController = KeyboardVisibilityController();
  //  // Query
  //  //print(
  //  //    'Keyboard visibility direct query: ${keyboardVisibilityController.isVisible}');
  //  // Subscribe
  //  keyboardSubscription =
  //      keyboardVisibilityController.onChange.listen((bool visible) {
  //    print('Keyboard visibility update. Is visible: $visible');
  //  });
  //}
  //
  //@override
  //void dispose() {
  //  keyboardSubscription.cancel();
  //  super.dispose();
  //}

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      print(isKeyboardVisible);
      return !isKeyboardVisible ? widget.child : Container();
      //return Text(
      //  'The keyboard is: ${isKeyboardVisible ? 'VISIBLE' : 'NOT VISIBLE'}',
      //);
    });
    //return widget.keepView
    //    ? Opacity(
    //        opacity: visible ? 1 : 0,
    //        child: IgnorePointer(ignoring: !visible, child: widget.child),
    //      )
    //    : Visibility(
    //        child: IgnorePointer(ignoring: !visible, child: widget.child),
    //        visible: visible);
  }
}
