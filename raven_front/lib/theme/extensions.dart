import 'package:flutter/material.dart';
import 'package:raven_mobile/theme/theme.dart';

extension ValueColorExtension on ThemeData {
  Color? get good => this.brightness == Brightness.light
      ? Colors.green.shade800 // Color(0xFF008a0b) based off orange
      : Colors.green.shade400; // Color(0xFFb6f122); based off orange
  Color? get bad => this.brightness == Brightness.light
      ? Colors.red.shade900 // Color(0xFFb80a48) based off orange
      : Colors.red.shade500; // Color(0xFFf1224f) based off orange
  Color? get fine => this.brightness == Brightness.light
      ? Colors.grey.shade900
      : Colors.grey.shade400;
  Color? get ravenOrange => Palette.ravenOrange;
  Color? get ravenBlue => Palette.ravenBlue;
}

extension TextStyleExtension on ThemeData {
  TextStyle? get mono => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 16.0,
          fontFamily: 'Courier',
          fontWeight: FontWeight.bold,
          color: Colors.black)
      : TextStyle(
          fontSize: 16.0, fontFamily: 'Courier', color: Colors.grey.shade200);
  TextStyle? get monoLink => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 16.0, fontFamily: 'Courier', color: Palette.ravenBlue)
      : TextStyle(
          fontSize: 16.0, fontFamily: 'Courier', color: Palette.ravenOrange);
  TextStyle? get annotate => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 14.0,
          fontStyle: FontStyle.italic,
          color: Colors.grey.shade700)
      : TextStyle(
          fontSize: 14.0,
          fontStyle: FontStyle.italic,
          color: Colors.grey.shade200);
}
