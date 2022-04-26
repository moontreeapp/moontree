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

class _KeyboardStateHidesWidget extends State<KeyboardHidesWidgetWithDelay>
    with SingleTickerProviderStateMixin {
  late List<StreamSubscription> listeners = [];
  KeyboardStatus? keyboardStatus = KeyboardStatus.down;
  late AnimationController controller;
  final Duration animationDuration = Duration(milliseconds: 150);
  //late Animation<double> _fadeAnimation;
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: const Offset(0, 1),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: controller,
    curve: Curves.decelerate,
  ));

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: animationDuration);
    //_fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(controller);
    listeners.add(streams.app.keyboard.listen((KeyboardStatus? value) async {
      if (value != keyboardStatus) {
        if (value == KeyboardStatus.down) {
          await Future.delayed(Duration(milliseconds: 100));
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
    controller.dispose();
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
    return keyboardStatus == KeyboardStatus.down
        ? () {
            controller.reset();
            controller.forward();
            return SlideTransition(
              position: _offsetAnimation,
              child: widget.child,
            );
            //return FadeTransition(
            //  opacity: _fadeAnimation,
            //  child: widget.child,
            //);
          }()
        : Container();
  }
}
