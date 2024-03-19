import 'package:flutter/material.dart';
import 'package:outline_gradient_button/outline_gradient_button.dart';
import 'package:moontree/presentation/theme/colors.dart';

class CarouselSelector extends StatelessWidget {
  const CarouselSelector({super.key});

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: SelectedIndicator(
          //onTap: () {
          //  print('do something');
          //},
          size: 0,
          strokeWidth: 0,
        ),
      );
}

class CenterIcon extends StatelessWidget {
  final double size;
  final Color color;
  const CenterIcon({
    super.key,
    required this.size,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: SelectedIndicator(
          //onTap: () {
          //  print('do something');
          //},
          color: color,
          size: size,
          image: null, //HypyrIcons.ad('ad').image,
        ),
      );
}

class SelectedIndicator extends StatelessWidget {
  final ImageProvider? image;
  final void Function()? onTap;
  final double size;
  final double strokeWidth;
  final Color color;
  const SelectedIndicator({
    super.key,
    this.image,
    this.onTap,
    this.size = 72,
    this.strokeWidth = 2.5,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) => OutlineGradientButton(
        onTap: onTap,
        strokeWidth: strokeWidth,
        padding: EdgeInsets.zero,
        radius: Radius.circular(260),
        //backgroundColor: Colors.red,
        gradient: LinearGradient(
          //colors: [AppColors.primary, AppColors.secondary],
          //colors: [Colors.white60, Colors.white60],
          colors: [color, color],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        child: Container(
            width: size,
            height: size,
            padding: const EdgeInsets.all(4),
            alignment: Alignment.center,
            child: image != null
                ? Container(
                    width: size - strokeWidth,
                    height: size - strokeWidth,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: AppColors.black60,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        image: DecorationImage(
                          image: image!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  )
                : null),
      );
}
