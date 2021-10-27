import 'package:flutter/material.dart';

class ButtonStyleComponents {
  ButtonStyleComponents();

  ButtonStyle get leftSideCurved => ButtonStyle(
      shape: MaterialStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0)))));

  ButtonStyle rightSideCurved(context, {bool disabled = false}) => ButtonStyle(
      backgroundColor: disabled
          ? MaterialStateProperty.all<Color>(Theme.of(context).disabledColor)
          : null,
      shape: MaterialStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0)))));

  ButtonStyle get curvedSides => _curvedButton();
  ButtonStyle disabledCurvedSides(context) => _curvedButton(context: context);

  static ButtonStyle _curvedButton({BuildContext? context}) => ButtonStyle(
      backgroundColor: context != null
          ? MaterialStateProperty.all<Color>(Theme.of(context).disabledColor)
          : null,
      shape: MaterialStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0)))));
}
