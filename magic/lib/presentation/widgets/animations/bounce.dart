import 'package:flutter/material.dart';
//GentleAnimation(child: Icon(Icons.star, size: 50),

class GentleAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double? distance;
  final Curve curve;

  GentleAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 1),
    this.distance,
    this.curve = Curves.easeIn,
  });

  @override
  _GentleAnimationState createState() => _GentleAnimationState();
}

class _GentleAnimationState extends State<GentleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: widget.distance).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
    );
  }
}
