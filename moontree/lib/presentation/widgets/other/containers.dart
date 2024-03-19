import 'package:flutter/material.dart';
import 'package:moontree/services/services.dart' show screen;

class OneThird extends StatelessWidget {
  final Widget? child;

  const OneThird({super.key, this.child});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: screen.widthOneThird,
        child: child,
      );
}

class TransparentAppBar extends StatelessWidget {
  final Widget? left;
  final Widget? center;
  final Widget? right;
  final double height;
  const TransparentAppBar(
      {super.key, this.left, this.center, this.right, this.height = 56});

  @override
  Widget build(BuildContext context) => SizedBox(
      height: height,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        left ?? const OneThird(),
        center ?? const OneThird(),
        right ?? const OneThird(),
      ]));
}
