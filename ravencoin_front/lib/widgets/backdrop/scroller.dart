/// scrollable wrapper
import 'package:flutter/material.dart';
import 'package:flutter/src/rendering/viewport_offset.dart';

class Scroller extends StatefulWidget {
  const Scroller({
    Key? key,
    required this.child,
    required this.controller,
  }) : super(key: key);
  final Widget child;
  final ScrollController controller;

  @override
  State<Scroller> createState() => _ScrollerState();
}

class _ScrollerState extends State<Scroller> {
  @override
  Widget build(BuildContext context) {
    return Scrollable(
        controller: widget.controller,
        viewportBuilder: (BuildContext context, ViewportOffset ignored) =>
            widget.child);
  }
}
