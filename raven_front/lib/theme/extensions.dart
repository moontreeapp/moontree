import 'package:flutter/material.dart';
import 'package:raven_mobile/theme/theme.dart';

extension ValueColorExtension on ThemeData {
  Color? get good => this.brightness == Brightness.light
      ? Colors.green.shade800
      : Colors.green.shade400;
  Color? get bad => this.brightness == Brightness.light
      ? Colors.red.shade900
      : Colors.red.shade500;
  Color? get fine => this.brightness == Brightness.light
      ? Colors.grey.shade900
      : Colors.grey.shade400;
  Color? get ravenOrange => Palette.ravenOrange;
  Color? get ravenBlue => Palette.ravenBlue;
}
