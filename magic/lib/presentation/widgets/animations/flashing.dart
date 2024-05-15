import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:magic/presentation/theme/colors.dart';

class FadeHighlight extends StatefulWidget {
  final Widget child;
  final void Function()? onEnd;
  final Color? color;
  final Color? background;
  final Duration? delay;
  final Duration? duration;
  const FadeHighlight({
    Key? key,
    required this.child,
    this.onEnd,
    this.color,
    this.background,
    this.delay,
    this.duration,
  }) : super(key: key);

  @override
  FadeHighlightState createState() => FadeHighlightState();
}

class FadeHighlightState extends State<FadeHighlight> {
  bool highlight = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay ?? const Duration(seconds: 2), unhighlight);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void unhighlight() {
    if (mounted) {
      setState(() => highlight = false);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedContainer(
      onEnd: widget.onEnd,
      duration: widget.duration ?? const Duration(seconds: 4),
      color: highlight
          ? widget.color ?? AppColors.primary60
          : widget.background ?? Colors.white,
      child: widget.child);
}

class FlashHighlight extends StatefulWidget {
  final Widget child;
  final void Function()? onEnd;
  final Color? color;
  final Color? background;
  final Duration? delay;
  final Duration? duration;
  final Duration? fadeInDuration;
  final Duration? fadeOutDuration;
  const FlashHighlight({
    super.key,
    required this.child,
    this.onEnd,
    this.color,
    this.background,
    this.delay,
    this.duration,
    this.fadeInDuration,
    this.fadeOutDuration,
  });

  @override
  FlashHighlightState createState() => FlashHighlightState();
}

class FlashHighlightState extends State<FlashHighlight> {
  bool? show;
  Duration? duration;

  @override
  void initState() {
    super.initState();
    Future.delayed(
        widget.delay ?? const Duration(milliseconds: 250), highlight);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onEnd() {
    if (show == true) {
      Future.delayed(
        widget.duration ?? const Duration(seconds: 1),
        unhighlight,
      );
      return;
    }
    if (show == false) {
      if (widget.onEnd != null) {
        widget.onEnd!();
      }
    }
  }

  void unhighlight() {
    if (mounted) {
      setState(() {
        show = false;
        duration = widget.fadeOutDuration;
      });
    }
  }

  void highlight() {
    if (mounted) {
      setState(() {
        show = true;
        duration = widget.fadeInDuration ?? const Duration(milliseconds: 750);
      });
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedContainer(
      onEnd: onEnd,
      duration: duration ?? const Duration(seconds: 2),
      color: show ?? false
          ? widget.color ?? AppColors.secondary
          : widget.background ?? Colors.white,
      child: widget.child);
}

class FadeFlashIcon extends StatefulWidget {
  final String assetName;
  final double width;

  const FadeFlashIcon(
      {required this.assetName, required this.width, super.key});

  @override
  FadeFlashIconState createState() => FadeFlashIconState();
}

class FadeFlashIconState extends State<FadeFlashIcon>
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
        return Opacity(
          opacity: _animation.value,
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
