import 'package:flutter/material.dart';
import 'package:client_front/presentation/utils/animation.dart' as animation;

class SlideOutIn extends StatefulWidget {
  final Widget left;
  final Widget right;
  final Duration duration;
  final bool enter;

  const SlideOutIn({
    required this.left,
    required this.right,
    this.duration = animation.slideDuration,
    this.enter = true,
  });

  @override
  _SlideOutInState createState() => _SlideOutInState();
}

class _SlideOutInState extends State<SlideOutIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _animationRight;
  late final Animation<Offset> _animationLeft;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animationRight = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));
    _animationLeft = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));
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
    return Stack(
      children: [
        SlideTransition(
          position: _animationLeft,
          child: widget.left,
        ),
        SlideTransition(
          position: _animationRight,
          child: widget.right,
        ),
      ],
    );
  }
}

class SlideUp extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool enter;
  final double heightPercentage;

  const SlideUp({
    required this.child,
    this.duration = animation.slideDuration,
    this.enter = true,
    this.heightPercentage = 1,
  });

  @override
  _SlideUpState createState() => _SlideUpState();
}

class _SlideUpState extends State<SlideUp> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<Offset> _animationUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _animationUp = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset(0, 1 - widget.heightPercentage),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));
    if (widget.enter) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    return Stack(
      children: [
        SlideTransition(
          position: _animationUp,
          child: widget.child,
        ),
      ],
    );
  }
}
