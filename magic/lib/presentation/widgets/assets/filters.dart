// to save without formatting: CTRL+K, CTRL+SHIFT+S
import 'package:flutter/material.dart';
import 'package:magic/domain/utils/maths.dart';

class Filters {
  static const ColorFilter sepia = ColorFilter.matrix(<double>[
    0.393, 0.769, 0.189, 0, 0, //
    0.349, 0.686, 0.168, 0, 0,
    0.272, 0.534, 0.131, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  static const ColorFilter greyscale = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ]);
  /*
  static const ColorFilter success = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0,      0,      0,      1, 0]);
  
  static const ColorFilter error= ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0,      0,      0,      1, 0]); 

    static const ColorFilter warning = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0,      0,      0,      1, 0]);
    */
}

class Grayscale extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const Grayscale({super.key, required this.child, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: enabled
          ? const ColorFilter.matrix([
              0.2126, 0.7152, 0.0722, 0, 0, //
              0.2126, 0.7152, 0.0722, 0, 0, //
              0.2126, 0.7152, 0.0722, 0, 0, //
              0, 0, 0, 0.5, 0, //
            ])
          : const ColorFilter.matrix([
              1, 0.0, 0.0, 0, 0, //
              0.0, 1, 0.0, 0, 0, //
              0.0, 0.0, 1, 0, 0, //
              0, 0, 0, 1, 0, //
            ]),
      child: child,
    );
  }
}

class GrayscaleSpectrum extends StatelessWidget {
  final Widget child;
  final double percent;
  final double red = 0.2126;
  final double green = 0.7152;
  final double blue = 0.0722;
  final double alpha = 0.5;

  const GrayscaleSpectrum({super.key, required this.child, this.percent = 0});

  @override
  Widget build(BuildContext context) {
    final r1 = positiveInterpolation(percent, 0, 1, 1, red);
    final r0 = positiveInterpolation(percent, 0, 1, 0, red);
    final g1 = positiveInterpolation(percent, 0, 1, 1, green);
    final g0 = positiveInterpolation(percent, 0, 1, 0, green);
    final b1 = positiveInterpolation(percent, 0, 1, 1, blue);
    final b0 = positiveInterpolation(percent, 0, 1, 0, blue);
    final a1 = positiveInterpolation(percent, 0, 1, 1, alpha);
    return ColorFiltered(
      colorFilter: percent == 1
          ? const ColorFilter.matrix([
              1, 0, 0, 0, 0, //
              0, 1, 0, 0, 0, //
              0, 0, 1, 0, 0, //
              0, 0, 0, 1, 0, //
            ])
          : ColorFilter.matrix([
              r1, g0, b0, 0.0, 0, //
              r0, g1, b0, 0.0, 0, //
              r0, g0, b1, 0.0, 0, //
              0, 0, 0, a1, 0, //
            ]),
      child: child,
    );
  }
}
