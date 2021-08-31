import 'package:flutter/material.dart';

ButtonStyle leftCurvedButton() => ButtonStyle(
    shape: MaterialStateProperty.all(RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            bottomLeft: Radius.circular(30.0)))));

ButtonStyle rightCurvedButton(context, {bool disabled = false}) => ButtonStyle(
    backgroundColor: disabled
        ? MaterialStateProperty.all<Color>(Theme.of(context).disabledColor)
        : null,
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
  static ButtonStyle rightSideCurved(context, {bool disabled = false}) =>
      rightCurvedButton(context, disabled: disabled);
  static ButtonStyle get curvedSides => curvedButton();
}
