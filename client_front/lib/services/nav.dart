/// experiment with manually handling transition logic and animation

import 'package:flutter/material.dart';
import 'package:client_front/components/components.dart';
import 'package:client_front/pages/pages.dart';

class NavWrap {
  void navigate<T>(
      //BuildContext context,
      //Future Function(String routeName, {Object? arguments}) navigation,
      //required String routeName,
      //Map<String, dynamic>? arguments,
      {
    required Future<T> Function() navCall,
    Function? before,
    Function? after,
  }) {
    if (before != null) {
      before();
    }
    //ScaffoldMessenger.of(context).clearSnackBars();
    //Navigator.of(components.routes.routeContext!).pushNamed(
    navCall();
    if (after != null) {
      after();
    }
  }

  void goTo(String link) {
    if (link == '/settings/about') {
      navigate(
        navCall: () => Navigator.of(components.routes.routeContext!).push(
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                pages.routes(components.routes.routeContext!)[link]!(
                    components.routes.routeContext!), //Page1(),
            transitionDuration: fadeDuration,
            reverseTransitionDuration: fadeDuration,
            transitionsBuilder: (_, animation, secondaryAnimation, child) =>
                FadeTransition(
              opacity: animation.drive(Tween<double>(begin: 0, end: 1)
                  .chain(CurveTween(curve: const DelayedCurve()))),
              child: FadeTransition(
                  opacity: secondaryAnimation.drive(
                      Tween<double>(begin: 1, end: 0)
                          .chain(CurveTween(curve: const CurveDelayed()))),
                  child: child),
            ),
          ),
        ),
        before: () => print('before'),
        after: () => print('after'),
      );
    }
  }
}

/*
*/

const slideDuration = Duration(milliseconds: 3000);
const fadeDuration = Duration(milliseconds: 3000);

class DelayedCurve extends Curve {
  const DelayedCurve() : super();

  @override
  double transformInternal(double t) {
    if (t < 0.5) {
      return 0.0;
    } else {
      return (t - 0.5) * 2.0;
    }
  }
}

class CurveDelayed extends Curve {
  const CurveDelayed() : super();

  @override
  double transformInternal(double t) {
    if (t > 0.5) {
      return 1.0;
    } else {
      return t * 2;
    }
  }
}
