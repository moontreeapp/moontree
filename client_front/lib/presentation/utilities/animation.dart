import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

const slideDuration = const Duration(milliseconds: 3000);
const fadeDuration = const Duration(milliseconds: 3000);
const slowFadeDuration = const Duration(milliseconds: 4000);

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

class DelayedCurve2 extends Curve {
  const DelayedCurve2() : super();

  @override
  double transformInternal(double t) {
    if (t < 0.5) {
      ///final x = (-2.0 * t) + 1;
      final x = t * 2;
      print('$t $x');
      return x;
    } else {
      print('$t 1.0');
      return 1.0;
    }
  }
}

/// fades out current content then fades in new content, even on back button.
/// we have no control over duration here so if we need to manage that we have
/// to use the `onGenerateRoute` solution in main.dart rather than `routes`.
/// the default duration is 300 ms, so 150 for fade out and 150 for fade in.
class FadeInPageTransitionsBuilder extends PageTransitionsBuilder {
  /// Constructs a page transition animation that slides the page up.
  const FadeInPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext? context,
    Animation<double> animation,
    Animation<double>? secondaryAnimation,
    Widget child,
  ) {
    return _FadeInPageTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation ?? animation,
        child: child);
  }
}

class _FadeInPageTransition extends StatelessWidget {
  _FadeInPageTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
        opacity: animation.drive(Tween<double>(begin: 0, end: 1)
            .chain(CurveTween(curve: const DelayedCurve()))),
        child: FadeTransition(
          opacity: secondaryAnimation.drive(Tween<double>(begin: 1, end: 0)
              .chain(CurveTween(curve: const CurveDelayed()))),
          child: child,
        ));
  }
}

/// alternative to above: use this in a generated routes solution.
class FadeFirstTransition extends PageRouteBuilder {
  final Widget child;

  FadeFirstTransition({
    required this.child,
  }) : super(
          transitionDuration: const Duration(milliseconds: 3000),
          reverseTransitionDuration: const Duration(milliseconds: 3000),
          pageBuilder: (context, animation, secondaryAnimation) => child,
          //transitionsBuilder: (
          //  BuildContext context,
          //  Animation<double> animation,
          //  Animation<double> secondaryAnimation,
          //  Widget child,
          //) {
          //  return FadeTransition(
          //    opacity: animation,
          //    child: FadeTransition(
          //      opacity: secondaryAnimation,
          //      child: child,
          //    ),
          //  );
          //}
        );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) =>
      FadeTransition(
          opacity: animation.drive(Tween<double>(begin: 0, end: 1)
              .chain(CurveTween(curve: const DelayedCurve()))),
          child: FadeTransition(
            opacity: secondaryAnimation.drive(Tween<double>(begin: 1, end: 0)
                .chain(CurveTween(curve: const CurveDelayed()))),
            child: child,
          ));
  //FadeTransition(
  //  opacity: animation,
  //  child: child,
  //);
}
