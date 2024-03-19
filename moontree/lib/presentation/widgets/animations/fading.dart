import 'package:flutter/material.dart';
import 'package:moontree/presentation/utils/animation.dart' as animation;

class FadeIn extends StatefulWidget {
  final Widget child;
  final bool enter;
  final Duration duration;
  final bool refade;
  final Duration delay;
  final Cubic? curve;

  const FadeIn({
    super.key,
    required this.child,
    this.enter = true,
    this.duration = animation.fadeDuration,
    this.refade = false,
    this.delay = Duration.zero,
    this.curve,
  });

  @override
  _FadeInState createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
//class _FadeInState extends State<FadeIn> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    initInternalState();
  }

  void initInternalState() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(
      begin: widget.enter ? 0.0 : 1.0,
      end: widget.enter ? 1.0 : 0.0,
    ).animate(
      CurvedAnimation(
          parent: _controller, curve: widget.curve ?? Curves.easeInOutCubic),
    );
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void didUpdateWidget(FadeIn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refade && widget.child != oldWidget.child) {
      //if (widget.enter != oldWidget.enter ||
      //    widget.curve != oldWidget.curve ||
      //    widget.delay != oldWidget.delay ||
      //    widget.duration != oldWidget.duration) {
      //  _controller.dispose();
      //  SchedulerBinding.instance.addPostFrameCallback((_) {
      //    initInternalState();
      //  });
      //} else {
      _controller.reset();
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
      //}
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
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

class FadeIn0 extends StatefulWidget {
  final Widget child;
  final bool enter;
  final Duration duration;
  final bool refade;
  final Duration delay;

  const FadeIn0({
    Key? key,
    required this.child,
    this.enter = true,
    this.duration = animation.fadeDuration,
    this.refade = false,
    this.delay = Duration.zero,
  }) : super(key: key);

  @override
  _FadeIn0State createState() => _FadeIn0State();
}

class _FadeIn0State extends State<FadeIn0> {
  ValueNotifier<double> _opacityNotifier = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  void _initAnimation() {
    Future.delayed(widget.delay, () {
      if (mounted) {
        _opacityNotifier.value = widget.enter ? 1.0 : 0.0;
      }
    });
  }

  @override
  void didUpdateWidget(FadeIn0 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refade && widget.child != oldWidget.child) {
      _opacityNotifier.value = 0.0; // Reset opacity to 0
      _initAnimation(); // Restart the animation
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: _opacityNotifier,
      builder: (context, opacityValue, child) {
        return AnimatedOpacity(
          opacity: opacityValue,
          duration: widget.duration,
          curve: Curves.easeInOutCubic,
          child: widget.child,
        );
      },
    );
  }
}

class FadeIn2 extends StatefulWidget {
  final Widget child;
  final bool enter;
  final Duration duration;
  final bool refade;
  final Duration delay;

  const FadeIn2({
    Key? key,
    required this.child,
    this.enter = true,
    this.duration = animation.fadeDuration,
    this.refade = false,
    this.delay = Duration.zero,
  }) : super(key: key);

  @override
  _FadeIn2State createState() => _FadeIn2State();
}

class _FadeIn2State extends State<FadeIn2> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool built = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    /// delay funcitonality doesn't work.
    //if (widget.delay > 0) {
    //  () async {
    //    await Future.delayed(Duration(milliseconds: widget.delay), () {
    //      _controller.forward();
    //    });
    //    _animation = Tween<double>(begin: 0, end: 1).animate(
    //        CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic))
    //      ..addListener(() {
    //        setState(() {});
    //      });
    //  }();
    //} else {
    _animation = Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic))
        //..addListener(() {
        //  setState(() {});
        //})
        ;
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
    //}
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //if (widget.enter) {
    //if (widget.refade) {
    //  _controller.forward(from: 0);
    //} else {

    //} else {
    //if (widget.refade) {
    //  _controller.reverse(from: 1);
    //} else {
    //Future.delayed(widget.delay, () {
    //  _controller.reverse();
    //});
    //}
    //}
    // //if (widget.refade && built && _controller.value == 1.0) {
    // //  built = false;
    // //  Future.delayed(widget.delay, () {
    // //    if (mounted) {
    // //      _controller.forward(from: 0);
    // //    }
    // //  });
    // //}
    // //if (!built && _controller.value == 1.0) {
    // //  built = true;
    // //}

    return AnimatedOpacity(
      opacity: _animation.value,
      curve: Curves.easeInOutCubic,
      duration: widget.duration,
      onEnd: null,
      alwaysIncludeSemantics: false,
      child: widget.child,
    );
  }
}

class FadeOut extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final bool enabled;
  final bool refade;
  final Curve curve;
  final bool away;
  const FadeOut({
    super.key,
    required this.child,
    this.duration = animation.fadeDuration,
    this.delay = Duration.zero,
    this.enabled = true,
    this.refade = false,
    this.away = false,
    this.curve = Curves.easeInOutCubic,
  });

  @override
  _FadeOutState createState() => _FadeOutState();
}

class _FadeOutState extends State<FadeOut> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _controller = AnimationController(
        vsync: this,
        duration: widget.duration,
      );
      _animation = Tween<double>(begin: 1, end: 0)
          .animate(CurvedAnimation(parent: _controller, curve: widget.curve))
        ..addListener(() {
          setState(() {});
        });

      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FadeOut oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refade) {
      _controller.reset();
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //_controller.forward();
    if (widget.enabled) {
      if (widget.away) {
        return ScaleTransition(
            scale: _animation,
            child: Opacity(
              opacity: _animation.value,
              child: widget.child,
            ));
      }
      return Opacity(
        opacity: _animation.value,
        child: widget.child,
      );
    }
    return widget.child;
  }
}

class FadeOutInBroken extends StatefulWidget {
  final Widget out;
  final Widget child;

  const FadeOutInBroken({
    Key? key,
    required this.out,
    required this.child,
  }) : super(key: key);

  @override
  _FadeOutInBrokenState createState() => _FadeOutInBrokenState();
}

class _FadeOutInBrokenState extends State<FadeOutInBroken>
    with TickerProviderStateMixin {
  late AnimationController _fadeOutController;
  late AnimationController _fadeInController;
  bool _showFirst = true;

  @override
  void initState() {
    super.initState();

    _fadeOutController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _fadeInController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _fadeOutController.forward().then((_) {
      setState(() {
        _showFirst = false;
        _fadeInController.forward();
      });
    });
  }

  @override
  void dispose() {
    _fadeOutController.dispose();
    _fadeInController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(seconds: 10),
      child: _showFirst
          ? FadeTransition(
              opacity: _fadeOutController,
              child: widget.out,
            )
          : FadeTransition(
              opacity: _fadeInController,
              child: widget.child,
            ),
    );
  }
}

class FadeOutIn extends StatefulWidget {
  final Widget out;
  final Widget child;
  final Duration outDuration;
  final Duration inDuration;

  const FadeOutIn({
    Key? key,
    required this.out,
    required this.child,
    this.outDuration = animation.fadeDuration,
    this.inDuration = animation.fadeDuration,
  }) : super(key: key);

  @override
  _FadeOutInState createState() => _FadeOutInState();
}

class _FadeOutInState extends State<FadeOutIn> {
  bool _out = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.outDuration, () => setState(() => _out = false));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_out) {
      return FadeOut(duration: widget.outDuration, child: widget.out);
    }
    return FadeIn(
        duration: widget.inDuration, child: widget.child, refade: true);
  }
}
