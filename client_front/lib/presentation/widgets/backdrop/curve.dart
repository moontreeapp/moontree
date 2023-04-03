import 'package:flutter/material.dart';

class FrontCurve extends StatefulWidget {
  final Widget? child;
  final double? height;
  final Alignment? alignment;
  final BorderRadius frontLayerBorderRadius;
  final List<BoxShadow> frontLayerBoxShadow;
  final bool fuzzyTop;
  final Color? color;

  const FrontCurve({
    Key? key,
    this.child,
    this.height,
    this.alignment,
    this.color,
    this.fuzzyTop = true,
    this.frontLayerBorderRadius = const BorderRadius.only(
      topLeft: Radius.circular(8),
      topRight: Radius.circular(8),
    ),
    this.frontLayerBoxShadow = const <BoxShadow>[
      BoxShadow(
        color: Color(0x33000000),
        offset: Offset(0, 1),
        blurRadius: 5,
      ),
      BoxShadow(
        color: Color(0x1F000000),
        offset: Offset(0, 3),
        blurRadius: 1,
      ),
      BoxShadow(
        color: Color(0x24000000),
        offset: Offset(0, 2),
        blurRadius: 2,
      ),
    ],
  }) : super(key: key);

  @override
  State<FrontCurve> createState() => _FrontCurveState();
}

class _FrontCurveState extends State<FrontCurve> {
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: widget.alignment ?? Alignment.bottomCenter,
        height: widget.height,
        decoration: BoxDecoration(
            borderRadius: widget.frontLayerBorderRadius,
            boxShadow: widget.frontLayerBoxShadow,
            color: widget.color ?? Colors.white),
        child: widget.fuzzyTop ? fuzzy() : widget.child);
  }

  Widget fuzzy() => Stack(alignment: Alignment.topCenter, children: <Widget>[
        widget.child ?? Container(),
        IgnorePointer(
            child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: widget.color ?? Colors.white,
                  borderRadius: widget.frontLayerBorderRadius,
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: <Color>[
                      Colors.white.withOpacity(0.0),
                      Colors.white,
                    ],
                  ),
                )))
      ]);
}
