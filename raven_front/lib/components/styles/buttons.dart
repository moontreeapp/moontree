import 'package:flutter/material.dart';
import 'package:raven_front/theme/theme.dart';

class ButtonStyleComponents {
  ButtonStyle bottom(
    BuildContext context, {
    bool disabled = false,
    bool invert = false,
  }) =>
      ButtonStyle(
        textStyle: MaterialStateProperty.all(
            Theme.of(context).textTheme.enabledButton),
        foregroundColor: MaterialStateProperty.all(AppColors.offBlack),
        side: MaterialStateProperty.all(BorderSide(
            color: disabled
                ? AppColors.primaryDisabled
                : invert
                    ? AppColors.white
                    : Theme.of(context).backgroundColor,
            width: 2,
            style: BorderStyle.solid)),
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
      );

  ButtonStyle word(
    BuildContext context, {
    bool chosen = false,
  }) =>
      ButtonStyle(
        textStyle:
            MaterialStateProperty.all(Theme.of(context).textTheme.bodyText1),
        foregroundColor: MaterialStateProperty.all(AppColors.black),
        backgroundColor: MaterialStateProperty.all(
            chosen ? AppColors.primaries[1] : AppColors.primaries[0]),
        side: MaterialStateProperty.all(
            BorderSide(width: 0, style: BorderStyle.none)),
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
      );
}
