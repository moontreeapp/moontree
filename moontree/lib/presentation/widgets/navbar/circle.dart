import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moontree/presentation/theme/colors.dart';

class CircleImage extends StatelessWidget {
  final ImageProvider image;
  final double? width;
  final double? height;
  final List<BoxShadow>? shadows;
  const CircleImage(
      {super.key, required this.image, this.width, this.height, this.shadows});

  @override
  Widget build(BuildContext context) => Container(
        width: width ?? 68,
        height: height ?? 68,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: AppColors.black60,
          boxShadow: shadows,
        ),
        child: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            image: DecorationImage(
              image: image,
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
}

class CirclePicture extends StatelessWidget {
  final SvgPicture picture;
  final double? size;
  const CirclePicture({super.key, required this.picture, this.size});

  @override
  Widget build(BuildContext context) => Container(
        width: size ?? 68,
        height: size ?? 68,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: AppColors.black60,
        ),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
          child: picture,
        ),
      );
}

class CircleIcon extends StatelessWidget {
  final Icon? icon;
  final Widget? child;
  final double? size;
  final Color? color;
  final bool full;
  const CircleIcon({
    super.key,
    this.icon,
    this.child,
    this.size,
    this.color,
    this.full = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: size ?? 68,
        height: size ?? 68,
        padding: EdgeInsets.only(bottom: full ? 0 : 3),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: color ?? AppColors.black60,
        ),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
          child: icon != null ? icon : child,
        ),
      );
}

class CircleShadowPainter extends CustomPainter {
  final Shadow shadow;
  final Paint shadowPaint;
  final Paint innerPaint;

  CircleShadowPainter({
    required this.shadow,
  })  : shadowPaint = shadow.toPaint(),
        innerPaint = Paint()..color = Colors.transparent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw shadow.
    final shadowPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..close();
    canvas.drawShadow(shadowPath, shadow.color, shadow.blurRadius, true);

    // Draw transparent inner circle.
    canvas.drawCircle(center, radius, innerPaint);
  }

  @override
  bool shouldRepaint(CircleShadowPainter oldDelegate) => false;
}

class CircleShadow extends StatelessWidget {
  final double size;
  final Shadow shadow;

  const CircleShadow({
    Key? key,
    required this.size,
    required this.shadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CircleShadowPainter(shadow: shadow),
      child: Container(
        width: size,
        height: size,
      ),
    );
  }
}
