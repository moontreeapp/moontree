import 'package:flutter/material.dart';

const immediateDuration = Duration(milliseconds: 1);
const instantDuration = Duration(milliseconds: 40);
const momentDuration = Duration(milliseconds: 80);
const fastFadeDuration = Duration(milliseconds: 120);
const fastSlideDuration = Duration(milliseconds: 120);
const quickSlideDuration = Duration(milliseconds: 180);
const quickFadeDuration = Duration(milliseconds: 180);
const slideDuration = Duration(milliseconds: 300);
const fadeDuration = Duration(milliseconds: 300);
const slowSlideDuration = Duration(milliseconds: 450);
const slowFadeDuration = Duration(milliseconds: 600);
const testDuration = Duration(milliseconds: 4000);

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
  const _FadeInPageTransition({
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
}
