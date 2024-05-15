import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
//GentleAnimation(child: Icon(Icons.star, size: 50),

class GentleAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double? distance;
  final Curve curve;

  const GentleAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 1),
    this.distance,
    this.curve = Curves.easeIn,
  });

  @override
  GentleAnimationState createState() => GentleAnimationState();
}

class GentleAnimationState extends State<GentleAnimation>
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

class BouncingIcon extends StatefulWidget {
  final String assetName;
  final double width;

  const BouncingIcon({super.key, required this.assetName, required this.width});

  @override
  BouncingIconState createState() => BouncingIconState();
}

class BouncingIconState extends State<BouncingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
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
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0,
              10 * (1 - _animation.value)), // Adjust the offset value as needed
          child: child,
        );
      },
      child: SvgPicture.asset(
        widget.assetName,
        colorFilter: const ColorFilter.mode(
          Colors.white,
          BlendMode.srcIn,
        ),
        width: widget.width,
      ),
    );
  }
}
