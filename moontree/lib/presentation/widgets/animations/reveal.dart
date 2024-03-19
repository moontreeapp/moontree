import 'package:flutter/material.dart';
import 'package:moontree/presentation/components/clippers.dart';
import 'package:moontree/services/services.dart' show screen;

class AnimatedOpening extends StatefulWidget {
  final double initialRadius;
  final double? finalRadius;
  final double? x;
  final double? y;
  final Duration? duration;
  final Widget? child;

  const AnimatedOpening({
    this.finalRadius,
    this.initialRadius = 0.0,
    this.x,
    this.y,
    this.duration = const Duration(seconds: 1),
    this.child,
  });

  @override
  _AnimatedOpeningState createState() => _AnimatedOpeningState();
}

class _AnimatedOpeningState extends State<AnimatedOpening>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration ?? const Duration(seconds: 1),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: widget.initialRadius,
      end: widget.finalRadius ?? (screen.app.height + screen.width) * 1.5,
    ).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward(from: 0.0);
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => TransparentCenterArea(
        x: widget.x,
        y: widget.y,
        radius: _animation.value,
        child: child,
      ),
      child: widget.child,
    );
  }
}

class TransparentCenterArea extends StatelessWidget {
  final double radius;
  final double? x;
  final double? y;
  final Widget? child;
  TransparentCenterArea({required this.radius, this.child, this.x, this.y});

  @override
  Widget build(BuildContext context) => ClipPath(
        clipper: TransparentClipper(radius: radius, x: x, y: y),
        child: child,
      );
}
