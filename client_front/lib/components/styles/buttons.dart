import 'package:flutter/material.dart';
import 'package:client_front/theme/theme.dart';

class ButtonStyleComponents {
  ButtonStyle bottom(
    BuildContext context, {
    bool disabled = false,
    bool invert = false,
    bool soft = false,
  }) =>
      ButtonStyle(
        textStyle: MaterialStateProperty.all(
            Theme.of(context).textTheme.enabledButton),
        foregroundColor: MaterialStateProperty.all(
            soft ? AppColors.black60 : AppColors.offBlack),
        side: MaterialStateProperty.all(BorderSide(
            color: disabled
                ? AppColors.primaryDisabled
                : invert
                    ? AppColors.white
                    : soft
                        ? AppColors.primaries[3]
                        : Theme.of(context).backgroundColor,
            width: 2, //soft ? 1 : 2,
            style: BorderStyle.solid)),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                (MediaQuery.of(context).size.height * 0.05263157895) * .5))),
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
        side: MaterialStateProperty.all(BorderSide.none),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                (MediaQuery.of(context).size.height * (32 / 760)) * .5))),
      );

  ButtonStyle wordBottom(BuildContext context) => ButtonStyle(
        textStyle: MaterialStateProperty.all(
            Theme.of(context).textTheme.enabledButton),
        foregroundColor: MaterialStateProperty.all(AppColors.black),
        backgroundColor: MaterialStateProperty.all(AppColors.primaries[0]),
        side: MaterialStateProperty.all(BorderSide.none),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                (MediaQuery.of(context).size.height * 0.05263157895) * .5))),
      );
}
