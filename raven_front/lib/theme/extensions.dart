import 'package:flutter/material.dart';
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
  TextStyle? get softButton => AppText.softButton;
  TextStyle? get invertButton => AppText.invertButton;
  TextStyle? get disabledButton => AppText.disabledButton;
  TextStyle? get enabledButton => AppText.enabledButton;
  TextStyle? get checkoutSubAsset => AppText.checkoutSubAsset;
  TextStyle? get checkoutItem => AppText.checkoutItem;
  TextStyle? get checkoutFees => AppText.checkoutFees;
  TextStyle? get checkoutFee => AppText.checkoutFee;
}

extension TextStyleExtension on ThemeData {}
