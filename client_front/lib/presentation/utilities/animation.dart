import 'package:flutter/widgets.dart';
import 'package:beamer/beamer.dart';

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

class FadeTransitionPage extends BeamPage {
  const FadeTransitionPage({
    LocalKey? key,
    required Widget child,
    String? title,
    bool keepQueryOnPop = false,
  }) : super(
            key: key,
            child: child,
            title: title,
            keepQueryOnPop: keepQueryOnPop);

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      opaque: true,
      pageBuilder: (_, __, ___) => child,
      transitionDuration: fadeDuration,
      reverseTransitionDuration: fadeDuration,
      transitionsBuilder: (_, animation, secondaryAnimation, child) =>
          FadeTransition(
        opacity: animation.drive(Tween<double>(begin: 0, end: 1)
            .chain(CurveTween(curve: const DelayedCurve()))),
        child: FadeTransition(
            opacity: secondaryAnimation.drive(Tween<double>(begin: 1, end: 0)
                .chain(CurveTween(curve: const CurveDelayed()))),
            child: child),
      ),
    );
  }
}
