import 'package:flutter/material.dart';

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

class RavenButtonStyle {
  RavenButtonStyle();

  static ButtonStyle get leftSideCurved => leftCurvedButton();
  static ButtonStyle get rightSideCurved => rightCurvedButton();
  static ButtonStyle get curvedSides => curvedButton();
}
