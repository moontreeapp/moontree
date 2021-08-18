/// Allows for importing two different ways, I prefer the later, See colors.dart
import 'package:flutter/material.dart';
import 'package:raven_mobile/components/styles/text.dart';

ButtonStyle leftCurvedButton() => ButtonStyle(
    shape: MaterialStateProperty.all(RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            bottomLeft: Radius.circular(30.0)))));

ButtonStyle rightCurvedButton() => ButtonStyle(
    shape: MaterialStateProperty.all(RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(30.0),
            bottomRight: Radius.circular(30.0)))));

ButtonStyle curvedButton() => ButtonStyle(
    shape: MaterialStateProperty.all(RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            bottomLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
            bottomRight: Radius.circular(30.0)))));

ButtonStyle disabledButton() => ButtonStyle(
      backgroundColor:
          MaterialStateProperty.all<Color>(Colors.grey[300] ?? Colors.white),
      textStyle:
          MaterialStateProperty.all<TextStyle>(RavenTextStyle().disabled),
    );

class RavenButtonStyle {
  RavenButtonStyle();

  ButtonStyle get leftSideCurved => leftCurvedButton();
  ButtonStyle get rightSideCurved => rightCurvedButton();
  ButtonStyle get curvedSides => curvedButton();
  ButtonStyle get disabled => disabledButton();
}
