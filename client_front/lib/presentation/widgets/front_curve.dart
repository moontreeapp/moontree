import 'package:flutter/material.dart';
import 'package:client_front/presentation/components/shapes.dart' as shapes;
import 'package:client_front/presentation/components/shadows.dart' as shadows;

class FrontCurve extends StatelessWidget {
  final Widget? child;
  final double? height;
  final Alignment alignment;
  final BorderRadius frontLayerBorderRadius;
  final List<BoxShadow> frontLayerBoxShadow;
  final bool fuzzyTop;
  final Color color;
  const FrontCurve({
    Key? key,
    this.child,
    this.height,
    this.alignment = Alignment.bottomCenter,
    this.color = Colors.white,
    this.fuzzyTop = true,
    this.frontLayerBorderRadius = shapes.topRoundedBorder16,
    this.frontLayerBoxShadow = shadows.frontLayer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
      alignment: alignment,
      height: height,
      //width: MediaQuery.of(context).size.width,
      //clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          borderRadius: frontLayerBorderRadius,
          boxShadow: frontLayerBoxShadow,
          color: color),
      child: fuzzyTop
          ? FuzzyTop(
              child: child,
              frontLayerBorderRadius: frontLayerBorderRadius,
              color: color)
          : child);
}

class FuzzyTop extends StatelessWidget {
  final Widget? child;
  final BorderRadius frontLayerBorderRadius;
  final Color color;

  const FuzzyTop({
    Key? key,
    required this.frontLayerBorderRadius,
    required this.color,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Stack(alignment: Alignment.topCenter, children: <Widget>[
        child ?? const SizedBox.shrink(),
        IgnorePointer(
            child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: frontLayerBorderRadius,
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
