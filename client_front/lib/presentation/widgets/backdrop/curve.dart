import 'package:flutter/material.dart';
import 'package:client_front/presentation/components/shapes.dart' as shapes;
import 'package:client_front/presentation/components/shadows.dart' as shadows;

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
    this.frontLayerBorderRadius = shapes.topRoundedBorder8,
    this.frontLayerBoxShadow = shadows.frontLayer,
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
