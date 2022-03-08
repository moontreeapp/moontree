import 'package:flutter/material.dart';
import 'package:raven_front/theme/theme.dart';

class ButtonStyleComponents {
  ButtonStyle bottom(BuildContext context, {bool disabled = false}) =>
      ButtonStyle(
        textStyle: MaterialStateProperty.all(Theme.of(context).enabledButton),
        foregroundColor: MaterialStateProperty.all(AppColors.offBlack),
        side: MaterialStateProperty.all(BorderSide(
            color: disabled
                ? AppColors.disabled
                : Theme.of(context).backgroundColor,
            width: 2,
            style: BorderStyle.solid)),
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
      );
}
