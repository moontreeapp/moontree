/// Allows for importing two different ways, I prefer the later
///
/// import 'package:raven_mobile/styles.dart' as styles;
/// RavenTextStyle().h2;
///
/// import 'package:raven_mobile/styles.dart';
/// RavenTextStyle().h2;
import 'package:flutter/material.dart';

TextStyle h1Style({Color? color}) {
  return TextStyle(
    fontSize: 24.0,
    letterSpacing: 2.0,
    color: color ?? Colors.white,
  );
}

TextStyle h2Style({Color? color}) {
  return TextStyle(
    fontSize: 18.0,
    letterSpacing: 2.0,
    color: color ?? Colors.white,
  );
}

TextStyle h3Style({Color? color}) {
  return TextStyle(
    fontSize: 16.0,
    letterSpacing: 2.0,
    color: color ?? Colors.white,
  );
}

TextStyle warningStyle() => TextStyle(
      color: Colors.red,
      fontSize: 22.0,
      fontWeight: FontWeight.bold,
    );

class RavenTextStyle {
  RavenTextStyle();

  TextStyle get h1 => h1Style();
  TextStyle get h2 => h2Style();
  TextStyle get h3 => h3Style();
  TextStyle get warning => warningStyle();
  TextStyle getH1({Color? color}) => h1Style(color: color);
  TextStyle getH2({Color? color}) => h2Style(color: color);
  TextStyle getH3({Color? color}) => h3Style(color: color);
}
