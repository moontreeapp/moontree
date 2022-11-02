import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';

class PeristentKeyboardWatcher extends StatefulWidget {
  const PeristentKeyboardWatcher({Key? key}) : super(key: key);

  @override
  _KeyboardStateHidesWidget createState() => _KeyboardStateHidesWidget();
}

class _KeyboardStateHidesWidget extends State<PeristentKeyboardWatcher> {
  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      if (isKeyboardVisible) {
        streams.app.keyboard.add(KeyboardStatus.up);
      } else {
        streams.app.keyboard.add(KeyboardStatus.down);
      }
      return Container();
    });
  }
}
