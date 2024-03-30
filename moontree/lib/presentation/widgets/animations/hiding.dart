import 'package:flutter/widgets.dart';
import 'package:moontree/presentation/utils/animation.dart';

class Hide extends StatelessWidget {
  final bool hidden;
  final Widget child;
  const Hide({super.key, required this.hidden, required this.child});

  @override
  Widget build(BuildContext context) => IgnorePointer(
      ignoring: hidden,
      child: AnimatedOpacity(
          opacity: hidden ? 0 : 1,
          curve: hidden ? Curves.easeOutQuint : Curves.easeInQuint,
          duration: slideDuration,
          child: child));
}
