import 'dart:async';
import 'package:flutter/material.dart';

import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';

class KeyboardHidesWidgetWithDelay extends StatefulWidget {
  final Widget child;
  final bool fade;

  const KeyboardHidesWidgetWithDelay({
    Key? key,
    required this.child,
    this.fade = false,
  }) : super(key: key);

  @override
  _KeyboardStateHidesWidget createState() => _KeyboardStateHidesWidget();
}

class _KeyboardStateHidesWidget extends State<KeyboardHidesWidgetWithDelay>
    with SingleTickerProviderStateMixin {
  late List<StreamSubscription<dynamic>> listeners =
      <StreamSubscription<dynamic>>[];
  KeyboardStatus? keyboardStatus = KeyboardStatus.down;
  final Duration animationDuration = Duration(milliseconds: 150);
  late AnimationController controller;
  late Animation<double> _fadeAnimation;
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: const Offset(0, 1),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: controller,
    curve: Curves.decelerate,
  ));
  bool keyboardWasUp = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: animationDuration);
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(controller);
    listeners.add(streams.app.keyboard.listen((KeyboardStatus? value) async {
      if (value != keyboardStatus) {
        if (value == KeyboardStatus.down) {
          await Future<void>.delayed(Duration(milliseconds: 100));
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
    for (final StreamSubscription<dynamic> listener in listeners) {
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
            var ret = keyboardWasUp
                ? (widget.fade
                    ? FadeTransition(
                        opacity: _fadeAnimation,
                        child: widget.child,
                      )
                    : SlideTransition(
                        position: _offsetAnimation,
                        child: widget.child,
                      ))
                : widget.child;
            keyboardWasUp = false;
            return ret;
          }()
        : () {
            keyboardWasUp = true;
            return Container();
          }();
  }
}
