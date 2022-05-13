import 'package:flutter/material.dart';
import 'package:raven_front/theme/theme.dart';

class AppText {
  /// Theme
  static TextStyle get h1 => TextStyle(
      fontSize: 24.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.normal,
      letterSpacing: 0.18,
      color: AppColors.black);

  static TextStyle get h2 => TextStyle(
      fontSize: 20.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      letterSpacing: 0.18,
      color: AppColors.black);

  static TextStyle get subtitle1 => TextStyle(
      fontSize: 16.0,
      height: 1.5,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      letterSpacing: 0.15,
      color: AppColors.black60);

  static TextStyle get subtitle2 => TextStyle(
      fontSize: 14.0,
      height: 1.714,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.normal,
      letterSpacing: 0.1,
      color: AppColors.black);

  static TextStyle get body1 => TextStyle(
      fontSize: 16.0,
      height: 1.5,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      letterSpacing: 0.5,
      color: AppColors.black);

  static TextStyle get body2 => TextStyle(
      fontSize: 14.0,
      height: 1.714,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      letterSpacing: 0.25,
      color: AppColors.black);

  static TextStyle get button => TextStyle(
      fontSize: 14.0,
      height: 1.143,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.normal,
      letterSpacing: 1.25,
      color: AppColors.black);

  static TextStyle get caption => TextStyle(
      fontSize: 12.0,
      height: 1.333,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      letterSpacing: 0.4,
      color: AppColors.black);

  static TextStyle get overline => TextStyle(
      fontSize: 10.0,
      height: 1.6,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.normal,
      letterSpacing: 1.5,
      color: AppColors.black);

  /// derivations
  static TextStyle get softButton => button.copyWith(
      fontWeight: FontWeights.semiBold, color: AppColors.black60);
  static TextStyle get invertButton =>
      button.copyWith(fontWeight: FontWeights.semiBold, color: AppColors.white);
  static TextStyle get disabledButton => button.copyWith(
      fontWeight: FontWeights.semiBold, color: AppColors.black38);
  static TextStyle get enabledButton => button.copyWith(
      fontWeight: FontWeights.semiBold, color: AppColors.offBlack);
  static TextStyle get link => body1.copyWith(
      fontWeight: FontWeights.semiBold, color: AppColors.primary);
  static TextStyle get checkoutFees =>
      caption.copyWith(height: 1, color: AppColors.black);
  static TextStyle get checkoutSubAsset =>
      body2.copyWith(fontWeight: FontWeights.bold, color: AppColors.black60);
  static TextStyle get checkoutItem => body2.copyWith(
      fontWeight: FontWeights.semiBold, color: AppColors.black60);
  static TextStyle get checkoutFee => body2.copyWith(
      fontWeight: FontWeights.semiBold, color: AppColors.black60);
}
