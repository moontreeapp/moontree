import 'dart:async';
import 'package:flutter/material.dart';

import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/app.dart';

class KeyboardHidesWidgetWithDelay extends StatefulWidget {
  final Widget child;

  const KeyboardHidesWidgetWithDelay({Key? key, required this.child})
      : super(key: key);

  @override
  _KeyboardStateHidesWidget createState() => _KeyboardStateHidesWidget();
}

class _KeyboardStateHidesWidget extends State<KeyboardHidesWidgetWithDelay> {
  late List<StreamSubscription> listeners = [];
  KeyboardStatus? keyboardStatus = KeyboardStatus.down;

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.keyboard.listen((KeyboardStatus? value) async {
      if (value != keyboardStatus) {
        if (value == KeyboardStatus.down) {
          await Future.delayed(Duration(milliseconds: 150));
        }
        if (mounted) {
          setState(() {
            keyboardStatus = value;
          });
        }
      }
    }));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //return Visibility(
    //    visible: keyboardStatus == KeyboardStatus.down ? true : false,
    //    child: widget.child);

    /// have it animate up:
    return keyboardStatus == KeyboardStatus.down ? widget.child : Container();
  }
}
