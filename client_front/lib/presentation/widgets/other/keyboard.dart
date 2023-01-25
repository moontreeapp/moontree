import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class KeyboardHidesWidget extends StatefulWidget {
  final Widget child;

  const KeyboardHidesWidget({Key? key, required this.child}) : super(key: key);

  @override
  _KeyboardStateHidesWidget createState() => _KeyboardStateHidesWidget();
}

class _KeyboardStateHidesWidget extends State<KeyboardHidesWidget> {
  @override
  Widget build(BuildContext context) => KeyboardVisibilityBuilder(
      builder: (BuildContext context, bool isKeyboardVisible) =>
          !isKeyboardVisible ? widget.child : Container()

      /// should we just make it invisible?
      //: Visibility(visible: false, child: widget.child)
      );
}
