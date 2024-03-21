import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:moontree/presentation/widgets/navbar/background.dart';

class AnimatedNavbarBackground extends StatefulWidget {
  final double height;
  final Duration duration;
  final bool out;

  const AnimatedNavbarBackground({
    super.key,
    required this.height,
    this.duration = const Duration(seconds: 1),
    this.out = false,
  });

  @override
  AnimatedNavbarBackgroundState createState() =>
      AnimatedNavbarBackgroundState();
}

class AnimatedNavbarBackgroundState extends State<AnimatedNavbarBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<List<double>> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    ); //..repeat(reverse: true);

    _animation = ListTween(
      begin: [
        1, 0, 0, 0, 0, // White
        0, 1, 0, 0, 0,
        0, 0, 1, 0, 0,
        0, 0, 0, 1, 0,
      ],
      end: [
        0.2126, 0.7152, 0.0722, 0.0, 0, // Grey
        0.2126, 0.7152, 0.0722, 0.0, 0,
        0.2126, 0.7152, 0.0722, 0.0, 0,
        0.0000, 0.0000, 0.0000, 0.9, 0,
      ],
    ).animate(_controller);
    if (widget.out) {
      _controller.reverse(from: 1);
    } else {
      _controller.forward();
    }
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
        return NavbarBackground(
          height: widget.height,
          color: Colors.transparent,
          imageFilter: ColorFilter.matrix(_animation.value),
        );
      },
    );
  }
}

class ListTween extends Tween<List<double>> {
  ListTween({List<double>? begin, List<double>? end})
      : super(begin: begin, end: end);

  @override
  List<double> lerp(double t) {
    return List.generate(begin!.length, (index) {
      return lerpDouble(begin![index], end![index], t)!;
    });
  }
}
