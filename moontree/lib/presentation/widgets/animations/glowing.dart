import 'package:flutter/material.dart';
import 'package:moontree/presentation/layers/navbar/components/carousel.dart';

class GlowingIndicator extends StatefulWidget {
  final Duration duration;
  final double size;
  const GlowingIndicator({
    super.key,
    required this.size,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  _GlowingIndicatorState createState() => _GlowingIndicatorState();
}

class _GlowingIndicatorState extends State<GlowingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.redAccent,
    ).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _startAnimation();
  }

  void _startAnimation() async => await _controller
      .forward()
      .then((_) async => await _controller.reverse());

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CenterIcon(
      size: widget.size,
      color: _colorAnimation.value!,
    );
  }
}
