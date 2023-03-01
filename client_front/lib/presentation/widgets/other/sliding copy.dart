import 'package:client_front/presentation/services/services.dart';
import 'package:flutter/material.dart';
import 'package:client_front/presentation/utilities/animation.dart'
    as animation;

class SlideOutIn extends StatefulWidget {
  final Widget exit;
  final Widget enter;
  final Duration duration;
  final bool left;

  const SlideOutIn({
    required this.exit,
    required this.enter,
    this.duration = animation.slideDuration,
    this.left = true,
  });

  @override
  _SlideOutInState createState() => _SlideOutInState();
}

class _SlideOutInState extends State<SlideOutIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<Offset>(
      begin: const Offset(0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, _) => Transform(
          alignment: Alignment.topCenter,
          transform: Matrix4.identity()
            ..translate(0.0, _animation.value.dy, 0.0),
          child: Container(
              width: screen.width * 2,
              height: screen.app.height / 2,
              child: ListView(scrollDirection: Axis.horizontal, children: [
                Container(width: screen.width, child: widget.exit),
                Container(width: screen.width, child: widget.enter)
              ]))));
//AnimatedBuilder(
//animation: _animation,
//builder: (BuildContext context, _) => Transform.translate(
//offset: _animation.value,
//child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
//Container(width: screen.width, child: widget.exit),
//Container(width: screen.width, child: widget.enter)
//]),
//));
  //SlideTransition(
  //      position: _animation,
  //      child: Row(
  //          mainAxisAlignment: MainAxisAlignment.start,
  //          children: [widget.exit, widget.enter]),
  //    );
}
