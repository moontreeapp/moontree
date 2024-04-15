import 'package:flutter/widgets.dart';
import 'package:magic/presentation/utils/animation.dart';

class Hide extends StatelessWidget {
  final bool hidden;
  final Duration? duration;
  final Widget child;
  const Hide(
      {super.key, required this.hidden, this.duration, required this.child});

  @override
  Widget build(BuildContext context) => IgnorePointer(
      ignoring: hidden,
      child: AnimatedOpacity(
          opacity: hidden ? 0 : 1,
          curve: hidden ? Curves.easeOutQuint : Curves.easeInQuint,
          duration: duration ?? slideDuration,
          child: child));
}
