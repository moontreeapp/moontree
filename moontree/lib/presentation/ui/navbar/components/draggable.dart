import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/cubits/cubits.dart';
import 'package:moontree/presentation/layers/navbar/components/background.dart';
import 'package:moontree/presentation/services/services.dart';
import 'package:moontree/presentation/utils/animation.dart' show slideDuration;

class DraggableSnappableSheet extends StatefulWidget {
  /// how quickly would slide animations happen?
  final Duration? duration;

  /// child to display when in normal position
  final Widget? child;

  /// child to display when in extended position
  final Widget? maxChild;

  /// child to display when in full position
  final Widget? fullChild;

  const DraggableSnappableSheet({
    super.key,
    this.duration,
    this.child,
    this.maxChild,
    this.fullChild,
  });

  @override
  DraggableSnappableSheetState createState() => DraggableSnappableSheetState();

  //void animateToPosition(double position) {
  //  if (super.key != null) {
  //    (super.key as GlobalKey<DraggableSnappableSheetState>)
  //        .currentState
  //        ?.animateToPosition(position);
  //  }
  //}
  //
  //void setHeightRange({double? minHeight, double? maxHeight}) {
  //  if (super.key != null) {
  //    (super.key as GlobalKey<DraggableSnappableSheetState>)
  //        .currentState
  //        ?.setHeightRange(minHeight, maxHeight);
  //  }
  //}
}

class DraggableSnappableSheetState extends State<DraggableSnappableSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double _currentPos;
  final double hidden = screen.app.height - screen.navbar.hiddenHeight;
  final double min = screen.app.height - screen.navbar.minHeight;
  final double mid = screen.app.height - screen.navbar.midHeight;
  final double nav = screen.app.height - screen.navbar.navHeight;
  final double max = screen.app.height - screen.navbar.maxHeight;
  final double full = screen.app.height - screen.navbar.fullHeight;
  late double maxHeight;
  late double minHeight;

  @override
  void initState() {
    super.initState();
    setHeightRange();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? slideDuration,
    );
    _currentPos = mid;
  }

  void setHeightRange([double? first, double? second]) {
    minHeight = math.min(first ?? 0, second ?? 0);
    maxHeight =
        math.max(first ?? screen.app.height, second ?? screen.app.height);
    //maxHeight = [hidden, min, mid, nav, max, full]
    //    .reduce((value, element) => math.max(value, element));
    //minHeight = [hidden, min, mid, nav, max, full]
    //    .reduce((value, element) => math.min(value, element));
  }

  void _updatePosition(DragUpdateDetails details) {
    final newPos = _currentPos + details.delta.dy;
    if (newPos > minHeight && newPos < maxHeight) {
      setState(() => _currentPos = newPos);
    }
    if (details.delta.dy != mid && cubits.centerAim.state.showCenter) {
      cubits.centerAim.update(showCenter: false);
      cubits.tagToolsMenu.update(section: TagToolsMenuSection.none);
    }
  }

  void _snapPosition(DragEndDetails details) {
    double getEndPosition(double high, double low) =>
        _currentPos < (high + low) / 2 ? high : low;

    late double endPosition;
    if (_currentPos > hidden) {
      endPosition = hidden;
    } else if (_currentPos > min) {
      endPosition = min;
    } else if (_currentPos > mid) {
      endPosition = getEndPosition(mid, min);
    } else if (_currentPos > nav) {
      endPosition = getEndPosition(nav, mid);
    } else if (_currentPos > max) {
      endPosition = getEndPosition(max, nav);
    } else if (_currentPos > full) {
      endPosition = getEndPosition(full, max);
    } else if (_currentPos < full) {
      endPosition = full;
    } else {
      endPosition = mid;
    }
    if (endPosition == hidden) {
      cubits.navbar.update(navbarHeight: NavbarHeight.hidden);
    } else if (endPosition == min) {
      cubits.navbar.update(navbarHeight: NavbarHeight.min);
    } else if (endPosition == mid) {
      cubits.navbar.update(navbarHeight: NavbarHeight.mid);
    } else if (endPosition == nav) {
      cubits.navbar.update(navbarHeight: NavbarHeight.nav);
    } else if (endPosition == max) {
      cubits.navbar.update(navbarHeight: NavbarHeight.max);
    } else if (endPosition == full) {
      cubits.navbar.update(navbarHeight: NavbarHeight.full);
    }
    animateToPosition(endPosition);
  }

  void animateToPosition(double position) {
    _animation = Tween<double>(begin: _currentPos, end: position).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    )..addListener(() {
        setState(() {
          _currentPos = _animation.value;
        });
      });
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateWidet() {
    if (_controller.value == 1.0) {
      if (_currentPos == hidden) {
        cubits.navbar.update(currentHeight: NavbarHeight.hidden);
      } else if (_currentPos == min) {
        cubits.navbar.update(currentHeight: NavbarHeight.min);
      } else if (_currentPos == mid) {
        if (!cubits.centerAim.state.showCenter) {
          cubits.centerAim.update(showCenter: true);
        }
        if (cubits.tagToolsMenu.state.section != TagToolsMenuSection.menu) {
          cubits.tagToolsMenu.update(section: TagToolsMenuSection.menu);
        }
        cubits.navbar.update(currentHeight: NavbarHeight.mid);
      } else if (_currentPos == nav) {
        cubits.navbar.update(currentHeight: NavbarHeight.nav);
      } else if (_currentPos == max) {
        cubits.navbar.update(currentHeight: NavbarHeight.max);
      } else if (_currentPos == full) {
        cubits.navbar.update(currentHeight: NavbarHeight.full);
      }
    }
  }

  double get childOpacity =>
      1 - ((_currentPos - mid).abs() / ((mid - max).abs() / 2)).clamp(0.0, 1.0);

  double get maxChildOpacity =>
      1 - ((_currentPos - max).abs() / ((nav - max).abs() / 2)).clamp(0.0, 1.0);

  double get fullChildOpacity =>
      1 -
      ((_currentPos - full).abs() / ((max - full).abs() / 2)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateWidet());
    return Positioned(
      top: _currentPos,
      left: 0,
      right: 0,
      child: GestureDetector(
          onVerticalDragUpdate: _updatePosition,
          onVerticalDragEnd: _snapPosition,
          child: Stack(alignment: Alignment.topCenter, children: [
            NavbarBackground(height: 760 * 2),
            widget.child == null
                ? const SizedBox.shrink()
                : IgnorePointer(
                    ignoring: _currentPos != mid && _currentPos != nav,
                    child: Opacity(opacity: childOpacity, child: widget.child)),
            widget.maxChild == null
                ? const SizedBox.shrink()
                : IgnorePointer(
                    ignoring: _currentPos != max,
                    child: Opacity(
                        opacity: maxChildOpacity, child: widget.maxChild)),
            widget.fullChild == null
                ? const SizedBox.shrink()
                : IgnorePointer(
                    ignoring: _currentPos != full,
                    child: Opacity(
                        opacity: fullChildOpacity, child: widget.fullChild)),
          ])),
    );
  }
}
