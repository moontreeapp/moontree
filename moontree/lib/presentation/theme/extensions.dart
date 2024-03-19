import 'package:flutter/material.dart';
import 'package:moontree/presentation/theme/theme.dart';

extension ValueColorExtension on ThemeData {
  Color? get good => this.brightness == Brightness.light
      ? AppColors.success
      : AppColors.success;
  Color? get bad =>
      this.brightness == Brightness.light ? AppColors.error : AppColors.error;
}

extension TextThemeStyleExtension on TextTheme {
  /// figma
  TextStyle? get h1 => AppText.h1;
  TextStyle? get h2 => AppText.h2;
  TextStyle? get sub1 => AppText.subtitle1;
  TextStyle? get sub2 => AppText.subtitle2;
  TextStyle? get body1 => AppText.body1;
  TextStyle? get body2 => AppText.body2;
  TextStyle? get button1 => AppText.button1;
  TextStyle? get caption1 => AppText.caption;
  TextStyle? get overline => AppText.overline;

  /// extras
  TextStyle? get link => AppText.link;
  TextStyle? get agreement => AppText.agreement;
  TextStyle? get question => AppText.question;
  TextStyle? underlined(TextStyle? style) => AppText.underlined(style);
  TextStyle? underlinedLink(TextStyle? style) => AppText.underlinedLink(style);
  TextStyle? notUnderlinedLink(TextStyle? style) =>
      AppText.notUnderlinedLink(style);
  TextStyle? get disabledButton => AppText.disabledButton;
  TextStyle? get enabledButton => AppText.enabledButton;
}
