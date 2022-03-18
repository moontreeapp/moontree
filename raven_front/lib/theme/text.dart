import 'package:flutter/material.dart';
import 'package:raven_front/theme/theme.dart';

class AppText {
  static TextStyle? get link => TextStyle(
      fontSize: 16.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      letterSpacing: 0.5,
      color: AppColors.primary);

  static TextStyle? get h1 => TextStyle(
      fontSize: 24.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.normal,
      letterSpacing: 0.18,
      color: AppColors.black);
  static TextStyle? get h1white => TextStyle(
      fontSize: 24.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.normal,
      letterSpacing: 0.18,
      color: AppColors.white);

  static TextStyle? get h2 => TextStyle(
      fontSize: 20.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      letterSpacing: 0.18,
      color: AppColors.black);
  static TextStyle? get h2white => TextStyle(
      fontSize: 20.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      letterSpacing: 0.18,
      color: AppColors.white);

  static TextStyle? get subtitle1 => TextStyle(
      fontSize: 16.0,
      height: 1.5,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      letterSpacing: 0.15,
      color: AppColors.black60);

  static TextStyle? get subtitle2 => TextStyle(
      fontSize: 14.0,
      height: 1.714,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.normal,
      letterSpacing: 0.1,
      color: AppColors.black);

  static TextStyle? get body1 => TextStyle(
      fontSize: 16.0,
      height: 1.5,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      letterSpacing: 0.5,
      color: AppColors.black);
  static TextStyle? get body1white => TextStyle(
      fontSize: 16.0,
      height: 1.5,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      letterSpacing: 0.5,
      color: AppColors.white);

  static TextStyle? get body2 => TextStyle(
      fontSize: 14.0,
      height: 1.714,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.normal,
      letterSpacing: 0.25,
      color: AppColors.black);

  static TextStyle? get button => TextStyle(
      fontSize: 14.0,
      height: 1.143,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.normal,
      letterSpacing: 1.25,
      color: AppColors.black);

  static TextStyle? get caption => TextStyle(
      fontSize: 12.0,
      height: 1.333,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.normal,
      letterSpacing: 0.4,
      color: AppColors.black);

  static TextStyle? get overline => TextStyle(
      fontSize: 10.0,
      height: 1.6,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.normal,
      letterSpacing: 1.5,
      color: AppColors.black);

////////////////////////////////////////////////////////////////////////////////

  static TextStyle? get subtitle1OffBlack => TextStyle(
      fontSize: 16.0,
      height: 1.5,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      letterSpacing: 0.15,
      color: AppColors.black87);

  static TextStyle? get subtitle1OffSmallLineHeight => TextStyle(
      textBaseline: TextBaseline.ideographic,
      fontSize: 16.0,
      height: 0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      letterSpacing: 0.15,
      color: AppColors.black60);

  static TextStyle? get textFieldError => TextStyle(
      fontSize: 12.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      letterSpacing: 0.4,
      color: AppColors.error);
  static TextStyle? get checkoutFees => TextStyle(
      fontSize: 12.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      letterSpacing: 0.4,
      color: AppColors.offBlack);

  static TextStyle? get checkoutSubAsset => TextStyle(
      fontSize: 14.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.bold,
      letterSpacing: 0.25,
      color: AppColors.black60);
  static TextStyle? get choices => TextStyle(
      fontSize: 14.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.bold,
      letterSpacing: 0.1,
      color: AppColors.black60);
  static TextStyle? get choicesBlue => TextStyle(
      fontSize: 14.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.bold,
      letterSpacing: 0.1,
      color: AppColors.primary);
  static TextStyle? get sendConfirmButton => TextStyle(
      fontSize: 14.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.bold,
      letterSpacing: 1.25,
      color: AppColors.primary);
  static TextStyle? get textButton => TextStyle(
      fontSize: 14.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.bold,
      letterSpacing: 1.25,
      color: AppColors.primary);
  static TextStyle? get viewData => TextStyle(
      fontSize: 14.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.bold,
      letterSpacing: 1.25,
      color: AppColors.primary);
  static TextStyle? get checkoutItem => TextStyle(
      fontSize: 14.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      letterSpacing: 0.25,
      color: AppColors.black60);
  static TextStyle? get checkoutFee => TextStyle(
      fontSize: 14.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      letterSpacing: 0.25,
      color: AppColors.black60);
  static TextStyle? get supportHeading => TextStyle(
      fontSize: 14.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      letterSpacing: 0.1,
      color: AppColors.offBlack);
  static TextStyle? get invertButton => TextStyle(
      fontSize: 14.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      letterSpacing: 1.25,
      color: AppColors.white);
  static TextStyle? get disabledButton => TextStyle(
      fontSize: 14.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      letterSpacing: 1.25,
      color: AppColors.black38);
  static TextStyle? get enabledButton => TextStyle(
      fontSize: 14.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      letterSpacing: 1.25,
      color: AppColors.offBlack);
  static TextStyle? get importedSize => TextStyle(
      fontSize: 14.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      letterSpacing: 0.25,
      color: AppColors.black38);
  static TextStyle? get snackMessage => TextStyle(
      fontSize: 14.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      letterSpacing: 0.25,
      color: AppColors.white);
  static TextStyle? get snackMessageBad => TextStyle(
      fontSize: 14.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      letterSpacing: 0.25,
      color: AppColors.error);

  static TextStyle? get remaining => TextStyle(
      fontSize: 14.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.regular,
      letterSpacing: 0.25,
      color: AppColors.offWhite);

  static TextStyle? get sendConfirm => TextStyle(
      fontSize: 14.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.regular,
      letterSpacing: 0.25,
      color: AppColors.black60);

  static TextStyle? get remainingRed => TextStyle(
      fontSize: 14.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.regular,
      letterSpacing: 0.25,
      color: AppColors.error);

  static TextStyle? get txDate => TextStyle(
      fontSize: 14.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.regular,
      letterSpacing: 0.25,
      color: AppColors.black60);
  static TextStyle? get tabName => TextStyle(
      fontSize: 14.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.medium,
      letterSpacing: 1.25,
      color: AppColors.white);
  static TextStyle? get tabNameInactive => TextStyle(
      fontSize: 14.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.medium,
      letterSpacing: 1.25,
      color: AppColors.white60);

  static TextStyle? get qrMessage => TextStyle(
      fontSize: 16.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.bold,
      letterSpacing: 0.14,
      color: AppColors.offWhite);
}
