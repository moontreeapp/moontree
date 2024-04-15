import 'package:flutter/material.dart';
import 'package:magic/domain/concepts/side.dart';
import 'package:magic/presentation/utils/animation.dart' as animation;

class SlideTo extends StatefulWidget {
  final Widget child;
  final bool enter;
  final Duration duration;
  final bool refade;
  final Duration delay;
  final double? startTop;
  final double? startLeft;
  final double? startRight;
  final double? startBottom;
  final double? endTop;
  final double? endLeft;
  final double? endRight;
  final double? endBottom;
  final Cubic? curve;
  final VoidCallback? onEnd;

  const SlideTo({
    super.key,
    required this.child,
    this.enter = true,
    this.duration = animation.fastSlideDuration,
    this.refade = false,
    this.delay = Duration.zero,
    this.curve,
    this.startTop,
    this.startLeft,
    this.startRight,
    this.startBottom,
    this.endTop,
    this.endLeft,
    this.endRight,
    this.endBottom,
    this.onEnd,
  }) : assert(
            (startTop != null && endTop != null) ||
                (startLeft != null && endLeft != null) ||
                (startRight != null && endRight != null) ||
                (startBottom != null && endBottom != null),
            'must provide a start and end position');

  @override
  _SlideToState createState() => _SlideToState();
}

class _SlideToState extends State<SlideTo> with SingleTickerProviderStateMixin {
//class _SlideToState extends State<SlideTo> with TickerProviderStateMixin {
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
      begin: widget.enter
          ? (widget.startTop ??
              widget.startLeft ??
              widget.startRight ??
              widget.startBottom)
          : (widget.endTop ??
              widget.endLeft ??
              widget.endRight ??
              widget.endBottom),
      end: widget.enter
          ? (widget.endTop ??
              widget.endLeft ??
              widget.endRight ??
              widget.endBottom)
          : (widget.startTop ??
              widget.startLeft ??
              widget.startRight ??
              widget.startBottom),
    ).animate(
      CurvedAnimation(
          parent: _controller, curve: widget.curve ?? Curves.easeInOutCubic),
    );
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward().then((value) => widget.onEnd?.call());
      }
    });
  }

  @override
  void didUpdateWidget(SlideTo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refade && widget.child != oldWidget.child) {
      _controller.reset();
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward().then((value) => widget.onEnd?.call());
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
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: widget.startTop != null ? _animation.value : null,
          left: widget.startLeft != null ? _animation.value : null,
          right: widget.startRight != null ? _animation.value : null,
          bottom: widget.startBottom != null ? _animation.value : null,
          child: widget.child,
        );
      },
    );
  }
}

class SlideOutIn extends StatefulWidget {
  final Widget left;
  final Widget right;
  final Duration duration;
  final bool enter;

  const SlideOutIn({
    super.key,
    required this.left,
    required this.right,
    this.duration = animation.slideDuration,
    this.enter = true,
  });

  @override
  _SlideOutInState createState() => _SlideOutInState();
}

class _SlideOutInState extends State<SlideOutIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _animationRight;
  late final Animation<Offset> _animationLeft;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animationRight = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));

    _animationLeft = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));

    _triggerAnimation();
  }

  @override
  void didUpdateWidget(SlideOutIn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enter != widget.enter) {
      _triggerAnimation();
    }
  }

  void _triggerAnimation() {
    if (widget.enter) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SlideTransition(
          position: _animationLeft,
          child: widget.left,
        ),
        SlideTransition(
          position: _animationRight,
          child: widget.right,
        ),
      ],
    );
  }
}

class SlideSide extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool enter;
  final Side side;

  const SlideSide({
    required this.child,
    this.duration = animation.slideDuration,
    this.enter = true,
    this.side = Side.left,
  });

  @override
  _SlideSideState createState() => _SlideSideState();
}

class _SlideSideState extends State<SlideSide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<Offset> _animation;
  late Offset _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    if (widget.enter) {
      _controller.forward(from: 0.0);
    } else {
      _controller.reverse(from: 1.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SlideSide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (mounted) {
      if (widget.enter) {
        _controller.forward(from: 0.0);
      } else {
        _controller.reverse(from: 1.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.side) {
      case Side.left:
        _offset = const Offset(-1, 0);
        break;
      case Side.right:
        _offset = const Offset(1, 0);
        break;
      case Side.top:
        _offset = const Offset(0, -1);
        break;
      case Side.bottom:
        _offset = const Offset(0, 1);
        break;
      default:
        _offset = const Offset(-1, 0);
    }
    _animation = Tween<Offset>(
      begin: _offset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCirc,
    ));
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}

class SlideOver extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Offset? begin;
  final Offset? end;
  final Curve? curve;

  const SlideOver({
    super.key,
    required this.child,
    this.duration = animation.slideDuration,
    this.delay = Duration.zero,
    this.begin,
    this.end,
    this.curve,
  });

  @override
  SlideOverState createState() => SlideOverState();
}

class SlideOverState extends State<SlideOver>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward(from: 0.0);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SlideOver oldWidget) {
    super.didUpdateWidget(oldWidget);
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward(from: 0.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _animation = Tween<Offset>(
      begin: widget.begin ?? const Offset(-1, 0),
      end: widget.end ?? Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve ?? Curves.easeInOutCirc,
    ));
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}

class SlideUp extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool enter;
  final double heightPercentage;
  final Duration delay;
  final double begin;
  final double end;
  final Function? then;
  const SlideUp({
    required this.child,
    this.duration = animation.slideDuration,
    this.enter = true,
    this.heightPercentage = 1,
    this.begin = 1,
    this.end = 1,
    this.delay = Duration.zero,
    this.then,
  });

  @override
  _SlideUpState createState() => _SlideUpState();
}

class _SlideUpState extends State<SlideUp> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<Offset> _animationUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _animationUp = Tween<Offset>(
      begin: Offset(0, widget.begin),
      end: Offset(0, widget.end - widget.heightPercentage),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));
    if (widget.enter) {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward(from: 0);
        }
      });
      //_controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.reverse(from: 1).then((value) => widget.then?.call());
        }
      });
    }

    return Stack(
      children: [
        SlideTransition(
          position: _animationUp,
          child: widget.child,
        ),
      ],
    );
  }
}

// /// allows you to slide a child widget in accordance with a scroll controller.
// /// will allow the child to slide off screen.
// /// records the current position of the scrollController on init and slides the
// /// child in accordance with the difference between the current position and the
// /// initial position as the position changes up to a maximum and down to a
// /// minimum difference
// class SlideByController extends StatefulWidget {
//   final Widget child;
//
//   /// How far should the slide go (in terms of pixels) in positive direction?
//   /// typically 0 (such as when a header slides down and back up)
//   final double min;
//
//   /// How far should the slide go (in terms of pixels) in positive direction?
//   /// typically the height of the child (for header slide case)
//   final double max;
//
//   /// the controller we must slide in sync with
//   final ScrollController scrollController;
//
//   const SlideByController({
//     this.min = 0,
//     required this.max,
//     required this.child,
//     required this.scrollController,
//   });
//
//   @override
//   _SlideByControllerState createState() => _SlideByControllerState();
// }
//
// class _SlideByControllerState
//     extends State<SlideByController> /*with SingleTickerProviderStateMixin*/ {
//   /*late final AnimationController _controller;*/
//   /*late final ScrollPosition initialPosition;*/
//   /*late final double slideRangeMin;*/
//   /*late final double slideRangeMax;*/
//
//   @override
//   void initState() {
//     super.initState();
//     /*_controller = AnimationController(vsync: this);*/
//     /*initialPosition = widget.scrollController.position;*/
//     /*slideRangeMin = widget.min + initialPosition;*/
//     /*slideRangeMax = widget.max + initialPosition;*/
//     /*setup listener, if position within slideRange then slide accordingly*/
//
//   }
//
//   @override
//   void dispose() {
//     /*_controller.dispose();*/
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SlideTransition(
//           position: /* movement with acceptable slide range */,
//           child: widget.child,
//         );
//   }
// }

/// allows you to slide a child widget in accordance with a scroll controller.
/// will allow the child to slide off screen.
/// records the current position of the scrollController on init and slides the
/// child in accordance with the difference between the current position and the
/// initial position as the position changes up to a maximum and down to a
/// minimum difference
class SlideByController extends StatefulWidget {
  final Widget child;

  /// How far should the slide go (in terms of pixels) in positive direction?
  /// typically 0 (such as when a header slides down and back up)
  final double min;

  /// How far should the slide go (in terms of pixels) in positive direction?
  /// typically the height of the child (for header slide case)
  final double max;

  /// where should it get reset to?
  final double initialPosition;

  /// the controller we must slide in sync with
  final ScrollController scrollController;

  /// inverts the sliding direction
  final bool invert;

  final VoidCallback? onMinimumReached;

  const SlideByController({
    this.invert = false,
    this.initialPosition = 0,
    this.min = 0,
    required this.max,
    required this.child,
    required this.scrollController,
    this.onMinimumReached,
  });

  @override
  _SlideByControllerState createState() => _SlideByControllerState();
}

class _SlideByControllerState extends State<SlideByController> {
  late double initialOffset;
  late double currentOffset;
  late double priorOffset;
  late double currentPos;
  bool reachedMinimum = false;

  @override
  void initState() {
    super.initState();
    initialOffset = widget.scrollController.position.pixels;
    currentOffset = initialOffset;
    priorOffset = currentOffset;
    currentPos = widget.initialPosition;
    widget.scrollController.addListener(recordIt);
  }

  void recordIt() {
    setState(() {
      if (priorOffset < currentOffset &&
          currentOffset > widget.scrollController.position.pixels &&
          widget.scrollController.position.pixels >
              widget.initialPosition.abs()) {
        currentPos = widget.initialPosition;
      }
      priorOffset = currentOffset;
      currentOffset = widget.scrollController.position.pixels;
      currentPos += (currentOffset - priorOffset) * (widget.invert ? -1 : 1);
      currentPos = currentPos.clamp(widget.min, widget.max);
      if (!reachedMinimum && currentPos == widget.min) {
        reachedMinimum = true;
        widget.onMinimumReached?.call();
      } else {
        reachedMinimum = false;
      }
    });
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(recordIt);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Transform.translate(
        offset: Offset(0, currentPos),
        child: widget.child,
      );
}
