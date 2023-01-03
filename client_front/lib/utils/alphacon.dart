library alphacon;

import 'package:flutter/material.dart' as material show Color;
import 'package:client_front/theme/colors.dart';

Map<String, List<List<int>>> colorCache = <String, List<List<int>>>{};

class Alphacon {
  Alphacon({
    material.Color? foreground,
    material.Color? background,
  })  : foregroundColor = foreground != null ? AppColors.rgb(foreground) : null,
        backgroundColor = background != null ? AppColors.rgb(background) : null;
  late List<int>? foregroundColor;
  late List<int>? backgroundColor;

  late String name;
  late String hashedName;

  void _generateColors() {
    backgroundColor =
        backgroundColor ?? AppColors.rgb(AppColors.backgroundColor(name));
    foregroundColor =
        foregroundColor ?? AppColors.rgb(AppColors.foregroundColor(name));
  }

  String baseName() => name.startsWith('#') || name.startsWith(r'$')
      ? name.substring(1, name.length)
      : name.endsWith('!')
          ? name.substring(0, name.length - 1)
          : name;

  // same between main asset and admin asset
  String commonName() =>
      name.endsWith('!') ? name.substring(0, name.length - 1) : name;

  ImageDetails generate(String text) {
    name = text;
    name = commonName();
    _generateColors();

    return ImageDetails(
      foreground: foregroundColor!,
      background: backgroundColor!,
    );
  }
}

class ImageDetails {
  ImageDetails({
    required this.foreground,
    required this.background,
  });
  List<int> foreground;
  List<int> background;
}
