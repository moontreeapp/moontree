import 'package:flutter/material.dart';
import 'package:client_front/presentation/utils/animation.dart' as animation;

class FadeIn extends StatefulWidget {
  final Widget child;
  final bool enter;
  final Duration duration;

  const FadeIn({
    required this.child,
    this.enter = true,
    this.duration = animation.fadeDuration,
  });

  @override
  _FadeInState createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic))
      ..addListener(() {
        setState(() {}); // why is this here?
      });

    //_controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.enter) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    return Opacity(
      opacity: _animation.value,
      child: widget.child,
    );
  }
}

class FadeOut extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const FadeOut({
    required this.child,
    this.duration = animation.fadeDuration,
  });

  @override
  _FadeOutState createState() => _FadeOutState();
}

class _FadeOutState extends State<FadeOut> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: 1, end: 0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic))
      ..addListener(() {
        setState(() {}); // why is this here?
      });

    //_controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward();
    return Opacity(
      opacity: _animation.value,
      child: widget.child,
    );
  }
}
