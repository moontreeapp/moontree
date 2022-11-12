library alphacon;

import 'package:ravencoin_front/theme/colors.dart';

var colorCache = Map<String, List<List<int>>>();

class Alphacon {
  late List<int>? foregroundColor;
  late List<int>? backgroundColor;

  late String name;
  late String hashedName;

  Alphacon({
    foreground,
    background,
  })  : this.foregroundColor =
            foreground != null ? AppColors.RGB(foreground) : null,
        this.backgroundColor =
            background != null ? AppColors.RGB(background) : null;

  void _generateColors() {
    var appColors = AppColors();
    backgroundColor =
        backgroundColor ?? AppColors.RGB(appColors.backgroundColor(name));
    foregroundColor =
        foregroundColor ?? AppColors.RGB(appColors.foregroundColor(name));
  }

  String baseName() => name.startsWith('#') || name.startsWith('\$')
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
  List<int> foreground;
  List<int> background;

  ImageDetails({
    required this.foreground,
    required this.background,
  });
}
