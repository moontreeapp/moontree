import 'package:flutter/material.dart';

class DraggableSnappableSheetExample extends StatefulWidget {
  final double min;
  final double max;
  final Widget? child;
  const DraggableSnappableSheetExample({
    super.key,
    this.min = 700,
    this.max = 0,
    this.child,
  });
  @override
  _DraggableSnappableSheetExampleState createState() =>
      _DraggableSnappableSheetExampleState();
}

class _DraggableSnappableSheetExampleState
    extends State<DraggableSnappableSheetExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double _topPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _topPosition = widget.min;
  }

  void _updatePosition(DragUpdateDetails details) {
    setState(() {
      _topPosition += details.delta.dy;
    });
  }

  void _snapPosition(DragEndDetails details) {
    double endPosition =
        _topPosition < (widget.max + widget.min) / 2 ? widget.max : widget.min;
    _animation = Tween<double>(
      begin: _topPosition,
      end: endPosition,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    )..addListener(() {
        setState(() {
          _topPosition = _animation.value;
        });
      });
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            top: _topPosition,
            left: 0,
            right: 0,
            child: GestureDetector(
              onVerticalDragUpdate: _updatePosition,
              onVerticalDragEnd: _snapPosition,
              child: Container(
                  height: 200, // Adjust height as needed
                  color: Colors.blue,
                  child: widget.child),
            ),
          ),
        ],
      ),
    );
  }
}
