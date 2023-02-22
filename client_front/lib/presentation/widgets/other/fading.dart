import 'package:flutter/material.dart';
import 'package:client_front/presentation/utilities/animation.dart'
    as animation;

class FadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const FadeIn({
    required this.child,
    this.duration = animation.fadeDuration,
  });

  @override
  _FadeInState createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic))
      ..addListener(() {
        setState(() {});
      });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _animation.value,
      child: widget.child,
    );
  }
}
