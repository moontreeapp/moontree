import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:moontree/presentation/widgets/assets/clippers.dart';
import 'package:moontree/presentation/theme/colors.dart';
import 'package:moontree/services/services.dart' show screen;

class NavbarBackground extends StatelessWidget {
  final Color color;
  final double? height;
  final double blurAmount;
  final ImageFilter? imageFilter;
  final Widget? child;
  const NavbarBackground({
    super.key,
    this.color = AppColors.black24,
    this.height,
    this.imageFilter,
    this.blurAmount = 0.0,
    this.child,
  });

  @override
  Widget build(BuildContext context) => ClipPath(
        clipper: FullNavCurvesClipper(),
        child: BackdropFilter(
          filter: imageFilter ??
              ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
          child: Container(
              width: screen.width,
              height: height,
              alignment: Alignment.topCenter,
              color: color,
              child: child ?? DragIndicator()),
        ),
      );
}

class DragIndicator extends StatelessWidget {
  const DragIndicator({super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: 24,
        color: Colors.transparent,
        alignment: Alignment.topCenter,
        padding: EdgeInsets.only(top: 12),
        child: Container(
            height: 4,
            width: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Colors.white24,
            )),
      );
}

class DraggableNavbarBackground extends StatefulWidget {
  final Color color;
  final double? initialTop;
  final double blurAmount;
  final ImageFilter? imageFilter;
  final Widget? child;
  final double? minTop;
  final double? maxTop;

  /// function called when maxTop is hit
  final Function? maxTopCallback;

  const DraggableNavbarBackground({
    Key? key,
    this.color = Colors.black,
    this.initialTop,
    this.imageFilter,
    this.blurAmount = 0.0,
    this.child,
    this.minTop,
    this.maxTop,
    this.maxTopCallback,
  }) : super(key: key);

  @override
  State<DraggableNavbarBackground> createState() =>
      _DraggableNavbarBackgroundState();
}

class _DraggableNavbarBackgroundState extends State<DraggableNavbarBackground> {
  double? topPosition;
  bool called = false;

  @override
  void initState() {
    super.initState();
    topPosition = widget.initialTop;
  }

  @override
  void didUpdateWidget(DraggableNavbarBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      topPosition = widget.initialTop;
      called = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          topPosition = (topPosition ?? screen.height * 0.5) + details.delta.dy;
          topPosition = topPosition!.clamp(widget.minTop ?? 0.0, screen.height);
        });
        if (!called &&
            widget.maxTop != null &&
            topPosition != null &&
            topPosition! >= widget.maxTop!) {
          called = true;
          widget.maxTopCallback?.call();
        }
      },
      child: Stack(
        children: [
          Positioned(
            top: topPosition,
            left: 0,
            right: 0,
            child: NavbarBackground(
              color: widget.color,
              height: screen.height - (topPosition ?? screen.height * 0.5),
              blurAmount: widget.blurAmount,
              imageFilter: widget.imageFilter,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
