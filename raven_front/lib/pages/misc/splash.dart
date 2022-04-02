import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';

import 'package:raven_back/raven_back.dart';

/// This works by creating an AnimationController instance and passing it
/// to the Lottie widget.
/// The AnimationController class has a rich API to run the animation in various ways.

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin {
  late final AnimationController _controller;
  BuildContext? givenContext;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this)
      ..value = 0
      ..addListener(() {
        if (_controller.value == 1) {
          streams.app.splash.add(false);
          Future.microtask(() => Navigator.pushReplacementNamed(
              context, '/loading',
              arguments: {}));
        } else {
          setState(() {
            // Rebuild the widget at each frame to update the "progress" label.
          });
        }
      });
    //Navigator.pushReplacementNamed(components.navigator.routeContext!, '/home');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    givenContext = context;
    return Scaffold(
      body: Lottie.asset(
        'assets/splash/moontree_v2_001.json',
        controller: _controller,
        onLoaded: (composition) {
          setState(() {
            _controller.duration = composition.duration;
            _controller.forward();
          });
        },
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.fitWidth,
      ),
      backgroundColor: Colors.white,
    );
  }
}
