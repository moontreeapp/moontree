import 'package:flutter/material.dart';
import 'package:magic/presentation/theme/theme.dart';
import 'package:magic/services/services.dart';

class Shimmer0 extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const Shimmer0({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 2),
  });

  @override
  Shimmer0State createState() => Shimmer0State();
}

class Shimmer0State extends State<Shimmer0>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: Container(
            width: screen.width - 32,
            height: screen.pane.midHeight - 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            )),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: const [
                        AppColors.background,
                        AppColors.foreground,
                        AppColors.background
                      ],
                      stops: const [0.4, 0.5, 0.6],
                      transform: SlidingGradientTransform(
                          slidePercent: _controller.value),
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcATop,
                  child: widget.child,
                );
              },
              child: widget.child,
            )));
  }
}

class SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, .5, 0.0);
  }
}

class FadeShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const FadeShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 1),
  });

  @override
  FadeShimmerState createState() => FadeShimmerState();
}

class FadeShimmerState extends State<FadeShimmer>
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

    _animation = Tween<double>(begin: 0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
