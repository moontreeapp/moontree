/// this was an attempt to put a lock screen on potentially any page so we can
/// have a 'locked' screen without an entire logout process. It unfortunately
/// did not work, citing the an overlay requirement when you'd go to type in
/// your password after returning to the app. Fortunately, however, it turns out
/// the design changed and we opted to merely perform a full logout after x
/// minutes of inactivity. perhaps we can put x in app settings at some point.
/// I'm leaving this here because someone with more flutter experience might be
/// able to solve it and I do anticipate we'll want this kind of a feature
/// eventually, although by that time I also anticipate we'll mostly use
/// biometric authentication rather than passwords as we do now, and the
/// biometric stuff seems to have compatible plugins that can maybe supply this
/// need for us pretty easily. anyway its here if we need it. to be used in main
/// `LockedScreen(child: child!)`
/// requires AppWaiter to set value of streams.app.locked.value on inactivity.

import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/widgets/widgets.dart';

class LockedScreen extends StatefulWidget {
  final Widget child;

  LockedScreen({required this.child, Key? key}) : super(key: key);

  @override
  _LockedScreen createState() => _LockedScreen();
}

class _LockedScreen extends State<LockedScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(children: [
        widget.child,
        if (streams.app.locked.value && services.password.required)

          /// both of these fixed the issue, but after verification of password
          /// and reloading of this widget, for some unknown reason it would
          /// send the user back to the splash screen. I think using these
          /// messes up the navigator from the MaterialApp somehow, because
          /// without a password, these never get executed and the build and
          /// pass through of the child works fine.
          //Navigator(
          //  onGenerateRoute: (_) => MaterialPageRoute(
          //      builder: (ctx) =>
          //Overlay(initialEntries: [
          //    OverlayEntry(
          //        builder: (context) =>
          //            Material(child:
          //VerifyPassword(parentState: this)
          /// therefore I believe in order to solve this issue more concretely
          /// you'd have to place a screen infront of the actaul widget.child,
          /// thus I introduced the Stack pattern (above), but then we moved
          /// away from this design altogether before fully implementing it.
          VerifyPassword()
      ]);
}
