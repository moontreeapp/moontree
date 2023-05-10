// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/material.dart';
import 'package:client_front/presentation/theme/theme.dart';

class AppText {
  /// Theme
  static TextStyle get h1 => const TextStyle(
      fontSize: 24.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.normal,
      letterSpacing: 0.18,
      color: AppColors.black);

  static TextStyle get h2 => const TextStyle(
      fontSize: 20.0,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      letterSpacing: 0.18,
      color: AppColors.black);

  static TextStyle get titleMedium => const TextStyle(
      fontSize: 16.0,
      height: 1.5,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      letterSpacing: 0.15,
      color: AppColors.black60);

  static TextStyle get titleSmall => const TextStyle(
      fontSize: 14.0,
      height: 1.714,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.normal,
      letterSpacing: 0.1,
      color: AppColors.black);

  static TextStyle get body1 => const TextStyle(
      fontSize: 16.0,
      height: 1.5,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      letterSpacing: 0.5,
      color: AppColors.black);

  static TextStyle get body2 => const TextStyle(
      fontSize: 14.0,
      height: 1.714,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      letterSpacing: 0.25,
      color: AppColors.black);

  static TextStyle get button => const TextStyle(
      fontSize: 14.0,
      height: 1.143,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.normal,
      letterSpacing: 1.25,
      color: AppColors.black);

  static TextStyle get bodySmall => const TextStyle(
      fontSize: 12.0,
      height: 1.333,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.semiBold,
      letterSpacing: 0.4,
      color: AppColors.black);

  static TextStyle get overline => const TextStyle(
      fontSize: 10.0,
      height: 1.6,
      fontFamily: 'Nunito',
      fontWeight: FontWeights.normal,
      letterSpacing: 1.5,
      color: AppColors.black);

  /// derivations
  static TextStyle get softButton => button.copyWith(
        fontWeight: FontWeights.semiBold,
        color: AppColors.primaries[6],
      );
  static TextStyle get invertButton => button.copyWith(
        fontWeight: FontWeights.semiBold,
        color: AppColors.white,
      );
  static TextStyle get disabledButton => button.copyWith(
        fontWeight: FontWeights.semiBold,
        color: AppColors.black38,
      );
  static TextStyle get enabledButton => button.copyWith(
        fontWeight: FontWeights.semiBold,
        color: AppColors.offBlack,
      );
  static TextStyle get link => body1.copyWith(
        fontWeight: FontWeights.semiBold,
        color: AppColors.primary,
      );
  static TextStyle get underlinedLink => link.copyWith(
        decoration: TextDecoration.underline,
      );
  static TextStyle get underlinedMenuLink => titleSmall.copyWith(
        decoration: TextDecoration.underline,
        color: const Color(0xFFE8EAF6),
        fontWeight: FontWeights.semiBold,
      );
  static TextStyle get checkoutFees => bodySmall.copyWith(
        height: 1,
        color: AppColors.black,
      );
  static TextStyle get checkoutSubAsset => body2.copyWith(
        fontWeight: FontWeights.bold,
        color: AppColors.black60,
      );
  static TextStyle get checkoutItem => body2.copyWith(
        fontWeight: FontWeights.semiBold,
        color: AppColors.black60,
      );
  static TextStyle get checkoutFee => body2.copyWith(
        fontWeight: FontWeights.semiBold,
        color: AppColors.black60,
      );
}
