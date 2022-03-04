import 'package:flutter/material.dart';
import 'package:raven_front/theme/extensions.dart';

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

  ButtonStyle bottom(BuildContext context, {bool disabled = false}) =>
      ButtonStyle(
        textStyle: MaterialStateProperty.all(Theme.of(context).enabledButton),
        foregroundColor: MaterialStateProperty.all(Color(0xDE000000)),
        side: MaterialStateProperty.all(BorderSide(
            color: disabled
                ? Color(0x615C6BC0) // Theme.of(context).disabledColor
                : Theme.of(context).backgroundColor,
            width: 2,
            style: BorderStyle.solid)),
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
      );
}
