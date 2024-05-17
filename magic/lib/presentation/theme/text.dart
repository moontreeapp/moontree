// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/material.dart';
import 'package:magic/presentation/theme/theme.dart';

class AppText {
  /// Theme
  static TextStyle get h1 => const TextStyle(
      fontFamily: 'Nunito',
      fontWeight: FontWeights.normal,
      fontSize: 24.0,
      height: null, // figma: 24
      letterSpacing: 0.18,
      color: AppColors.black);

  static TextStyle get h2 => const TextStyle(
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      fontSize: 20.0,
      height: 1.4, // figma: 24
      letterSpacing: 0.15,
      color: AppColors.black);

  static TextStyle get subtitle1 => const TextStyle(
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      fontSize: 16.0,
      height: 1.625, // figma: 24
      letterSpacing: 0.15,
      color: AppColors.black60);

  static TextStyle get subtitle2 => const TextStyle(
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      fontSize: 14.0,
      height: 1.714, // figma: 24
      letterSpacing: 0.1,
      color: AppColors.black);

  static TextStyle get body1 => const TextStyle(
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      fontSize: 16.0,
      height: 1.625, // figma: 24
      letterSpacing: 0.5,
      color: AppColors.black);

  static TextStyle get body2 => const TextStyle(
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      fontSize: 14.0,
      height: 1.714, // figma: 24
      letterSpacing: 0.25,
      color: AppColors.black);

  static TextStyle get button1 => const TextStyle(
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      fontSize: 14.0,
      height: 1.3, // figma: 18
      letterSpacing: 1.25, // figma: 1.25 px
      color: AppColors.black);

  static TextStyle get caption => const TextStyle(
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      fontSize: 12.0,
      height: 1.5, // figma: 16
      letterSpacing: 0.004, // figma: 0.4 %
      color: AppColors.black);

  static TextStyle get overline => const TextStyle(
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      fontSize: 10.0,
      height: 1.7, // figma: 16
      letterSpacing: 1.5, // figma: 1.5 px
      color: AppColors.black);

  static TextStyle get agreement => const TextStyle(
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      fontSize: 14.0,
      height: 1.714,
      letterSpacing: 0.25,
      color: AppColors.black60);

  static TextStyle get question => const TextStyle(
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      fontSize: 12.0,
      height: 1.1427,
      letterSpacing: 0.25,
      color: AppColors.black87);

  static TextStyle get identiconLarge => h1.copyWith(
        color: AppColors.white87,
        height: null,
      );

  static TextStyle get identiconHuge => h1.copyWith(
        color: AppColors.white87,
        height: 2,
      );

  static TextStyle get disabledButton => button1.copyWith(
        fontWeight: FontWeights.semiBold,
        color: AppColors.white87,
      );
  static TextStyle get enabledButton => button1.copyWith(
        fontWeight: FontWeights.semiBold,
        color: AppColors.white,
      );
  static TextStyle get link => body1.copyWith(
        color: AppColors.black60,
      );
  static TextStyle underlined([TextStyle? style]) => (style ?? body1).copyWith(
        decoration: TextDecoration.underline,
      );
  static TextStyle underlinedLink([TextStyle? style]) =>
      (style ?? body1).copyWith(
        decoration: TextDecoration.underline,
        color: AppColors.primary50,
        fontWeight: FontWeights.semiBold,
      );
  static TextStyle notUnderlinedLink([TextStyle? style]) =>
      (style ?? body1).copyWith(
        color: AppColors.primary50,
        fontWeight: FontWeights.semiBold,
      );
  static TextStyle get wholeFiat => h1.copyWith(
        fontWeight: FontWeights.bold,
        color: AppColors.white,
        fontSize: 48,
        height: 1.2,
      );
  static TextStyle get partFiat => h1.copyWith(
        fontWeight: FontWeights.bold,
        color: AppColors.white67,
        height: null,
      );

  static TextStyle get wholeHolding =>
      h1.copyWith(fontWeight: FontWeights.bold, color: AppColors.white);
  static TextStyle get partHolding =>
      h1.copyWith(fontWeight: FontWeights.bold, color: AppColors.white67);
  static TextStyle get partHoldingBright =>
      h1.copyWith(fontWeight: FontWeights.bold, color: AppColors.white87);
  static TextStyle get usdHolding =>
      subtitle1.copyWith(color: AppColors.white60);
  static TextStyle get parentsAssetName =>
      subtitle1.copyWith(color: AppColors.white60);
  static TextStyle get childAssetName =>
      subtitle1.copyWith(color: Colors.white);
  static TextStyle get parentsAssetNameDark =>
      subtitle1.copyWith(color: AppColors.black60);
  static TextStyle get childAssetNameDark =>
      subtitle1.copyWith(color: Colors.black87);

  static TextStyle get labelHolding =>
      caption.copyWith(color: AppColors.white87, fontWeight: FontWeights.bold);
}
