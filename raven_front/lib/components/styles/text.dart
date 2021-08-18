/// Allows for importing two different ways, I prefer the later, See colors.dart
import 'package:flutter/material.dart';
import 'package:raven_mobile/components/styles/colors.dart';

TextStyle h1Text({Color? color}) =>
    TextStyle(fontSize: 24.0, letterSpacing: 2.0, color: color ?? Colors.white);

TextStyle h2Text({Color? color}) =>
    TextStyle(fontSize: 18.0, letterSpacing: 2.0, color: color ?? Colors.white);

TextStyle h3Text({Color? color}) =>
    TextStyle(fontSize: 16.0, letterSpacing: 2.0, color: color ?? Colors.white);

TextStyle nameText() => TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);

TextStyle warningText() =>
    TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.red);

TextStyle disabledText() => TextStyle(color: RavenColor().disabled);
TextStyle inText() => TextStyle(fontSize: 18.0, color: RavenColor().good);
TextStyle outText() => TextStyle(fontSize: 18.0, color: RavenColor().bad);
TextStyle zeroText() => TextStyle(fontSize: 18.0, color: RavenColor().fine);
TextStyle whisperText() =>
    TextStyle(fontSize: 16.0, color: RavenColor().whisper);

class RavenTextStyle {
  RavenTextStyle();

  TextStyle get h1 => h1Text();
  TextStyle get h2 => h2Text();
  TextStyle get h3 => h3Text();
  TextStyle get name => nameText();
  TextStyle get warning => warningText();
  TextStyle get disabled => disabledText();
  TextStyle get good => inText();
  TextStyle get bad => outText();
  TextStyle get fine => zeroText();
  TextStyle get whisper => whisperText();
  TextStyle getH1({Color? color}) => h1Text(color: color);
  TextStyle getH2({Color? color}) => h2Text(color: color);
  TextStyle getH3({Color? color}) => h3Text(color: color);
}

class RavenText {
  final String text;
  RavenText(this.text);

  Text get h1 => Text(text, style: h1Text());
  Text get h2 => Text(text, style: h2Text());
  Text get h3 => Text(text, style: h3Text());
  Text get name => Text(text, style: nameText());
  Text get warning => Text(text, style: warningText());
  Text get disabled => Text(text, style: disabledText());
  Text get good => Text(text, style: inText());
  Text get bad => Text(text, style: outText());
  Text get fine => Text(text, style: zeroText());
  Text get whisper => Text(text, style: whisperText());
  Text getH1({Color? color}) => Text(text, style: h1Text(color: color));
  Text getH2({Color? color}) => Text(text, style: h2Text(color: color));
  Text getH3({Color? color}) => Text(text, style: h3Text(color: color));
}
