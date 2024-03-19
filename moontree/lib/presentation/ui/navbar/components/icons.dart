import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moontree/presentation/theme/colors.dart';
import 'package:moontree/services/services.dart' show screen;
import 'package:moontree/presentation/layers/navbar/components/circle.dart';

class ShadedIcon extends StatelessWidget {
  final double? size;
  final double? iconSize;
  final Color? color;
  final String? iconPath;
  final IconData? iconData;
  final Widget? child;
  final bool full;
  const ShadedIcon({
    super.key,
    this.size,
    this.color,
    this.iconPath,
    this.iconData,
    this.iconSize,
    this.child,
    this.full = false,
  });

  @override
  Widget build(BuildContext context) => Container(
      alignment: Alignment.center,
      height: size ?? screen.navbar.carouselHeight,
      width: size ?? screen.navbar.itemWidth,
      child: iconPath != null
          ? CirclePicture(
              size: size == null ? null : (size! + 6.0),
              picture: SvgPicture.asset(iconPath!,
                  colorFilter: ColorFilter.mode(
                    color ?? AppColors.white87,
                    BlendMode.dstIn,
                  ),
                  height: size,
                  width: size))
          : iconData != null
              ? CircleIcon(
                  size: size == null ? null : (size! + 6.0),
                  icon: Icon(
                    iconData!,
                    color: color ?? AppColors.white87,
                    size: size == null
                        ? iconSize == null
                            ? null
                            : iconSize
                        : (size! - 8.0),
                  ))
              : CircleIcon(
                  size: full ? 73 : null,
                  full: full,
                  color: color,
                  child: Container(
                    child: child,
                  )));
}

class ShadedIcon2 extends StatelessWidget {
  final double? width;
  final double? height;
  final double? iconSize;
  final Color? color;
  final IconData? iconData;
  const ShadedIcon2({
    super.key,
    this.width,
    this.height,
    this.color,
    this.iconData,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) => Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      child: Container(
        width: height,
        alignment: Alignment.center,
        padding: const EdgeInsets.only(bottom: 4.5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100), color: AppColors.black60),
        child: Icon(
          iconData!,
          color: color ?? AppColors.white87,
          size: iconSize,
        ),
      ));
}
