import 'package:flutter/material.dart';

class ColorPair {
  final int colorInt1, colorInt2;
  const ColorPair(this.colorInt1, this.colorInt2);
  Color get color1 => Color(colorInt1);
  Color get color2 => Color(colorInt2);
}

const gradients = [
  ColorPair(0xFFC93538, 0xFF993436),
  ColorPair(0xFF99CBFB, 0xFF376898),
  ColorPair(0xFF656696, 0xFF343434),
  ColorPair(0xFFFD9941, 0xFFCA663A),
  ColorPair(0xFF9BCCCC, 0xFFCBCB9D),
  ColorPair(0xFF9BCCCC, 0xFF9BCCCC),
  ColorPair(0xFF6BCCCC, 0xFF689BCA),
  ColorPair(0xFFFECBCC, 0xFFDE5942),
  ColorPair(0xFF986898, 0xFF376797),
  ColorPair(0xFFFECB45, 0xFFFD9A41),
  ColorPair(0xFFFECBCD, 0xFFCB6999),
  ColorPair(0xFF9BCB6C, 0xFF9BCB6C),
  ColorPair(0xFFC96767, 0xFF353565),
];

class CircleGradient extends CustomPainter {
  final ColorPair colors;

  CircleGradient(this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    // The 'offset' is how "off center" the gradient is within the circle
    var offset = 0.75;
    RadialGradient gradient = RadialGradient(
      center: Alignment(-offset, -offset),
      radius: 0.5 + offset * 2,
      colors: <Color>[colors.color1, colors.color2],
    );

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.longestSide / 2,
      Paint()
        ..shader = gradient.createShader(
            // If the `size` is not a square, we calculate a square using
            // the longestSide, and center the gradient
            Rect.fromLTWH(
          (size.width - size.longestSide) / 2,
          (size.height - size.longestSide) / 2,
          size.longestSide,
          size.longestSide,
        )),
    );
  }

  @override
  // After the first paint, nothing about our gradient will change,
  // so no need to repaint
  bool shouldRepaint(CircleGradient oldDelegate) => false;
}

class PopCircle extends StatelessWidget {
  static const ColorPair defaultColorPair = ColorPair(0xFFC93538, 0xFF993436);

  final ColorPair colorPair;
  final EdgeInsetsGeometry padding;
  final Size size;

  PopCircle({
    this.colorPair = PopCircle.defaultColorPair,
    this.padding = const EdgeInsets.all(0),
    this.size = const Size(400, 400),
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: CustomPaint(painter: CircleGradient(colorPair)),
        ),
      );
}
