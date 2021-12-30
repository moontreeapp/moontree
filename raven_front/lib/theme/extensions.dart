import 'package:flutter/material.dart';
import 'package:raven_front/theme/theme.dart';

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

  /// from new specs
  //icon for holding size: 40x40
  //arrow for holding size: 24x24 (7.4w 12h) #000000
  //text for holding names (subtitle1):
  TextStyle? get holdingName => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.normal,
          letterSpacing: 0.5,
          color: Colors.black.withOpacity(0.87))
      : TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.normal,
          letterSpacing: 0.5,
          color: Colors.black.withOpacity(0.87));
  //text for holding values (secondarytext):
  TextStyle? get holdingValue => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.bold,
          letterSpacing: 0.25,
          color: Colors.black.withOpacity(0.6))
      : TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.bold,
          letterSpacing: 0.25,
          color: Colors.black.withOpacity(0.6));
  TextStyle? get pageName => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 20.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w600, //semibold
          letterSpacing: 0.15,
          color: Colors.black.withOpacity(0.87))
      : TextStyle(
          fontSize: 20.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          color: Colors.black.withOpacity(0.87));
  TextStyle? get pageValue => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 24.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.normal,
          letterSpacing: 0.18,
          color: Colors.black.withOpacity(0.87))
      : TextStyle(
          fontSize: 24.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.normal,
          letterSpacing: 0.18,
          color: Colors.black.withOpacity(0.87));
  //shadows on app bar: shadow blend mode multiply
  //#00000024 x0dp y4dp blur5dp
  //#0000001F  0    1       10
  //#00000033  0    2       4
}
