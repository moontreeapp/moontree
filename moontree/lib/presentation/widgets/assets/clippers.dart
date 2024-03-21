import 'dart:math';
import 'package:flutter/material.dart';
import 'package:moontree/services/services.dart' show screen;

class FullNavCurvesClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, size.height)
    ..lineTo(0, 29)
    ..quadraticBezierTo(0, 21, 10, 17)
    ..quadraticBezierTo(size.width / 2, -17, size.width - 10, 17)
    ..quadraticBezierTo(size.width, 21, size.width, 29)
    ..lineTo(size.width, size.height)
    ..close();

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class AntiNavCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, 0)
    ..lineTo(0, size.height)
    //..quadraticBezierTo(0, 32, 10, 17)
    ..quadraticBezierTo(
        (size.width) / 2, size.height - 29, size.width, size.height)
    //..quadraticBezierTo(size.width, 32, size.width, 40)
    ..lineTo(size.width, size.height)
    ..lineTo(size.width, 0)
    ..close();

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class CircleClipper extends CustomClipper<Path> {
  final double value;
  final double? x;
  final double? y;
  CircleClipper({required this.value, this.x, this.y});

  double ratio(double height, double width) =>
      min(height, width) / max(height, width);
  double rectangleModifier(double height, double width) =>
      1.0 + 0.414 * ratio(height, width);

  @override
  Path getClip(Size size) {
    final width = size.width > 0 ? size.width : screen.width;
    final height = size.width > 0 ? size.height : screen.height;
    return Path()
      ..addOval(Rect.fromCircle(
        center: Offset(x ?? width / 2, y ?? height / 2),
        radius: value * max(height, width) * rectangleModifier(height, width),
      ))
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class TransparentClipper extends CustomClipper<Path> {
  final double radius;
  final double? x;
  final double? y;
  TransparentClipper({required this.radius, this.x, this.y});

  @override
  Path getClip(Size size) => Path()
    ..addRect(Rect.fromPoints(Offset(0, 0), Offset(size.width, size.height)))
    ..addOval(Rect.fromCircle(
        center: Offset(x ?? size.width / 2, y ?? size.height / 2),
        radius: radius))
    ..fillType = PathFillType.evenOdd;

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class CurveLPainter extends CustomPainter {
  final Color color;
  const CurveLPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path()
      //..lineTo(0,0)
      ..quadraticBezierTo(
        0,
        size.height / 2,
        size.width,
        size.height / 2,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class LoopLPainter extends CustomPainter {
  final Color color;
  const LoopLPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // assumes a size of 64
    final path = Path()
      ..moveTo(32, 0)
      ..lineTo(32, 32)
      ..quadraticBezierTo(
        32,
        64,
        16,
        64,
      )
      ..quadraticBezierTo(
        0,
        64,
        0,
        48,
      )
      ..quadraticBezierTo(
        0,
        32,
        16,
        32,
      )
      ..quadraticBezierTo(
        32,
        32,
        32,
        48,
      )
      //fix
      ..quadraticBezierTo(
        32,
        48,
        48,
        48,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
