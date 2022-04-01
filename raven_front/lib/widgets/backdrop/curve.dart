import 'package:flutter/material.dart';

class FrontCurve extends StatefulWidget {
  final Widget? child;
  final double? height;
  final Alignment? alignment;
  final BorderRadius frontLayerBorderRadius;
  final List<BoxShadow> frontLayerBoxShadow;
  final bool fuzzyTop;

  const FrontCurve({
    Key? key,
    this.child,
    this.height,
    this.alignment,
    this.fuzzyTop = false,
    this.frontLayerBorderRadius = const BorderRadius.only(
      topLeft: Radius.circular(8),
      topRight: Radius.circular(8),
    ),
    this.frontLayerBoxShadow = const [
      BoxShadow(
        color: const Color(0x33000000),
        offset: Offset(0, 1),
        blurRadius: 5,
      ),
      BoxShadow(
        color: const Color(0x1F000000),
        offset: Offset(0, 3),
        blurRadius: 1,
      ),
      BoxShadow(
        color: const Color(0x24000000),
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
        //padding: EdgeInsets.only(top: widget.fuzzyTop ? 8 : 0.0),
        alignment: widget.alignment ?? Alignment.bottomCenter,
        height: widget.height,
        decoration: BoxDecoration(
            borderRadius: widget.frontLayerBorderRadius,
            boxShadow: widget.frontLayerBoxShadow,
            color: Colors.white),
        child: widget.fuzzyTop ? fuzzy() : widget.child);
  }

  Widget fuzzy() => Stack(alignment: Alignment.topCenter, children: [
        widget.child ?? Container(),
        Container(
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: widget.frontLayerBorderRadius,
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white,
                ],
              ),
              //boxShadow: [
              //  BoxShadow(
              //      color: const Color(0xFFFFFFFF),
              //      offset: Offset(0, 2),
              //      blurRadius: 1),
              //  BoxShadow(
              //      color: const Color(0x1FFFFFFF),
              //      offset: Offset(0, 3),
              //      blurRadius: 2),
              //  BoxShadow(
              //      color: const Color(0x3DFFFFFF),
              //      offset: Offset(0, 4),
              //      blurRadius: 4),
              //]
            )),
      ]);
}
