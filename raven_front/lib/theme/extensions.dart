import 'package:flutter/material.dart';
import 'package:raven_front/theme/colors.dart';
import 'package:raven_front/theme/text.dart';
import 'package:raven_front/theme/theme.dart';

extension ValueColorExtension on ThemeData {
  Color? get good => this.brightness == Brightness.light
      ? AppColors.success
      : AppColors.success;
  Color? get bad =>
      this.brightness == Brightness.light ? AppColors.error : AppColors.error;
}

extension TextThemeStyleExtension on TextTheme {
  TextStyle? get link => AppText.link;
  TextStyle? get subtitle1OffBlack => AppText.subtitle1OffBlack;
  TextStyle? get subtitle1Black => AppText.subtitle1Black;
}

extension TextStyleExtension on ThemeData {
  TextStyle? get supportHeading => AppText.supportHeading;
  TextStyle? get textFieldError => AppText.textFieldError;
  TextStyle? get remaining => AppText.remaining;
  TextStyle? get remainingRed => AppText.remainingRed;
  TextStyle? get choices => AppText.choices;
  TextStyle? get choicesBlue => AppText.choicesBlue;
  TextStyle? get sendConfirm => AppText.sendConfirm;
  TextStyle? get sendConfirmButton => AppText.sendConfirmButton;
  TextStyle? get textButton => AppText.textButton;
  TextStyle? get invertButton => AppText.invertButton;
  TextStyle? get disabledButton => AppText.disabledButton;
  TextStyle? get enabledButton => AppText.enabledButton;
  TextStyle? get importedSize => AppText.importedSize;
  TextStyle? get snackMessage => AppText.snackMessage;
  TextStyle? get snackMessageBad => AppText.snackMessageBad;
  TextStyle? get txDate => AppText.txDate;
  TextStyle? get tabName => AppText.tabName;
  TextStyle? get tabNameInactive => AppText.tabNameInactive;
  TextStyle? get viewData => AppText.viewData;
  TextStyle? get qrMessage => AppText.qrMessage;
  TextStyle? get checkoutSubAsset => AppText.checkoutSubAsset;
  TextStyle? get checkoutItem => AppText.checkoutItem;
  TextStyle? get checkoutFees => AppText.checkoutFees;
  TextStyle? get checkoutFee => AppText.checkoutFee;
}
