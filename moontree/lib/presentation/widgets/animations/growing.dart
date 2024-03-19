import 'dart:math';
import 'package:flutter/material.dart';
import 'package:moontree/presentation/utils/animation.dart';
import 'package:moontree/services/services.dart' show screen;

class GrowingCircleContent extends StatelessWidget {
  final double x;
  final double y;
  final Widget child;
  const GrowingCircleContent({
    super.key,
    this.x = 0,
    this.y = 0,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
              top: y,
              left: x,
              child: GrowingAnimation(
                rebuild: true,
                begin: 0.0,
                end: (screen.app.height + screen.width) * 1.5,
                child: child,
              )),
        ],
      );
}

class GrowingCircle extends StatelessWidget {
  final double x;
  final double y;
  final double? radius;
  final bool rebuild;
  final Duration? duration;
  final Duration? delay;
  const GrowingCircle({
    super.key,
    this.x = 0,
    this.y = 0,
    this.radius,
    this.rebuild = false,
    this.duration,
    this.delay,
  });

  @override
  Widget build(BuildContext context) => ColorFiltered(
        colorFilter: ColorFilter.mode(
          Colors.white.withOpacity(1.0),
          BlendMode.srcOut,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                backgroundBlendMode: BlendMode.dstOut,
              ),
            ),
            if (x == 0 && y == 0)
              Align(
                  alignment: Alignment.center,
                  child: GrowingAnimation(
                    duration: duration,
                    delay: delay ?? Duration.zero,
                    rebuild: rebuild,
                    begin: 0.0,
                    end: radius ?? max(screen.app.height, screen.width) * 1.2,
                    child: Container(
                      height: 1,
                      width: 1,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.width / 2,
                        ),
                      ),
                    ),
                  ))
            else
              Positioned(
                  top: y,
                  left: x,
                  child: GrowingAnimation(
                    duration: duration,
                    rebuild: true,
                    begin: 0.0,
                    end: radius ?? max(screen.app.height, screen.width) * 1.2,
                    child: Container(
                      height: 1,
                      width: 1,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.width / 2,
                        ),
                      ),
                    ),
                  )),
          ],
        ),
      );
}

class GrowingAnimation extends StatefulWidget {
  final Widget child;
  final Duration? duration;
  final Duration delay;
  final double? begin;
  final double? end;
  final bool reverse;
  final bool rebuild;
  const GrowingAnimation({
    super.key,
    required this.child,
    this.begin,
    this.end,
    this.duration,
    this.delay = Duration.zero,
    this.reverse = false,
    this.rebuild = false,
  });

  @override
  _GrowingAnimation createState() => _GrowingAnimation();
}

class _GrowingAnimation extends State<GrowingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? fadeDuration * 5,
    );
    final Animation<double> curveAnimation = CurvedAnimation(
        parent: _controller, curve: Curves.easeInOutCubicEmphasized);
    // Curves.easeInExpo //Curves.easeInQuart //Curves.easeInQuint
    // Curves.easeOutCubic
    // Curves.easeInOutCubicEmphasized

    _scaleAnimation =
        Tween(begin: widget.begin ?? 0.0, end: widget.end ?? 100.0)
            .animate(curveAnimation);
    if (!widget.rebuild && widget.reverse) {
      _controller.reverse(from: 1.0);
    } else {
      Future.delayed(widget.delay, () => _controller.forward(from: 0.0));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rebuild && widget.reverse) {
      _controller.reverse(from: 1.0);
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward(from: 0.0);
        }
      });
    }
    return ScaleTransition(scale: _scaleAnimation, child: widget.child);
  }
}

/// must be in stack
class TranslatePosition extends StatefulWidget {
  final Widget child;
  final double? startLeft;
  final double? startTop;
  final double? startRight;
  final double? startBottom;
  final double? endLeft;
  final double? endTop;
  final double? endRight;
  final double? endBottom;
  final Duration? duration;
  final bool isExpanded;
  const TranslatePosition({
    super.key,
    required this.child,
    this.startLeft,
    this.startTop,
    this.startRight,
    this.startBottom,
    this.endLeft,
    this.endTop,
    this.endRight,
    this.endBottom,
    this.duration,
    this.isExpanded = false,
  });

  @override
  Translate_PositionState createState() => Translate_PositionState();

  static Duration get defaultDuraiton => slideDuration;
}

class Translate_PositionState extends State<TranslatePosition> {
  //bool isExpanded = false;

  @override
  Widget build(BuildContext context) => AnimatedPositioned(
        curve: Curves.easeInOutCubic,
        duration: widget.duration ?? TranslatePosition.defaultDuraiton,
        left: widget.isExpanded ? widget.startLeft : widget.endLeft,
        top: widget.isExpanded ? widget.startTop : widget.endTop,
        right: widget.isExpanded ? widget.startRight : widget.endRight,
        bottom: widget.isExpanded ? widget.startBottom : widget.endBottom,
        child: widget.child,
      );
}
