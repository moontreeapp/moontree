import 'package:flutter/material.dart';
import 'package:moontree/presentation/layers/navbar/components/background.dart'
    show NavbarBackground;

class DeBlurAnimation extends StatefulWidget {
  const DeBlurAnimation({super.key});

  @override
  _DeBlurAnimationState createState() => _DeBlurAnimationState();
}

class _DeBlurAnimationState extends State<DeBlurAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _blurAnimation = Tween<double>(
      begin: 10.0,
      end: 0.0,
    ).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _blurAnimation,
        builder: (context, child) =>
            NavbarBackground(blurAmount: _blurAnimation.value),
      );
}
