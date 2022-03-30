/// scrollable wrapper
import 'package:flutter/material.dart';

class Scroller extends StatefulWidget {
  final Widget child;
  final ScrollController controller;

  const Scroller({
    Key? key,
    required this.child,
    required this.controller,
  }) : super(key: key);

  @override
  State<Scroller> createState() => _ScrollerState();
}

class _ScrollerState extends State<Scroller> {
  @override
  Widget build(BuildContext context) {
    return Scrollable(
        controller: widget.controller,
        viewportBuilder: ((context, ignored) => widget.child));
  }
}
