/// Allows for importing two different ways, I prefer the later
///
/// import 'package:raven_mobile/styles.dart' as styles;
/// RavenColor().appBar;
///
/// import 'package:raven_mobile/styles.dart';
/// RavenColor().appBar;
import 'package:flutter/material.dart';

Color seeThrough() => Colors.transparent;
Color? appBarColor() => Colors.blue[900];
Color? backArrowColor() => Colors.blue[900];
Color? backgroundColor() => Colors.blue[50];

class RavenColor {
  RavenColor();

  Color get appBar => appBarColor() ?? seeThrough();
  Color get backArrow => backArrowColor() ?? seeThrough();
  Color get background => backgroundColor() ?? seeThrough();
}
