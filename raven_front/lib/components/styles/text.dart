/// Allows for importing two different ways, I prefer the later
///
/// import 'package:raven_mobile/styles.dart' as styles;
/// RavenTextStyle().h2;
///
/// import 'package:raven_mobile/styles.dart';
/// RavenTextStyle().h2;
import 'package:flutter/material.dart';

TextStyle h1Text({Color? color}) {
  return TextStyle(
    fontSize: 24.0,
    letterSpacing: 2.0,
    color: color ?? Colors.white,
  );
}

TextStyle h2Text({Color? color}) {
  return TextStyle(
    fontSize: 18.0,
    letterSpacing: 2.0,
    color: color ?? Colors.white,
  );
}

TextStyle h3Text({Color? color}) {
  return TextStyle(
    fontSize: 16.0,
    letterSpacing: 2.0,
    color: color ?? Colors.white,
  );
}

class RavenTextStyle {
  RavenTextStyle();

  TextStyle get h1 => h1Text();
  TextStyle get h2 => h2Text();
  TextStyle get h3 => h3Text();
  TextStyle getH1({Color? color}) => h1Text(color: color);
  TextStyle getH2({Color? color}) => h2Text(color: color);
  TextStyle getH3({Color? color}) => h3Text(color: color);
}
