import 'dart:ui';

import 'package:flutter/material.dart';

extension CloneTextStyleExtension on TextStyle {
  TextStyle replace({
    bool? inherit,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    TextLeadingDistribution? leadingDistribution,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? debugLabel,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    String? package,
    TextOverflow? overflow,
  }) =>
      TextStyle(
        inherit: inherit ?? this.inherit,
        color: color ?? this.color,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        fontSize: fontSize ?? this.fontSize,
        fontWeight: fontWeight ?? this.fontWeight,
        fontStyle: fontStyle ?? this.fontStyle,
        letterSpacing: letterSpacing ?? this.letterSpacing,
        wordSpacing: wordSpacing ?? this.wordSpacing,
        textBaseline: textBaseline ?? this.textBaseline,
        height: height ?? this.height,
        leadingDistribution: leadingDistribution ?? this.leadingDistribution,
        locale: locale ?? this.locale,
        foreground: foreground ?? this.foreground,
        background: background ?? this.background,
        shadows: shadows ?? this.shadows,
        fontFeatures: fontFeatures ?? this.fontFeatures,
        decoration: decoration ?? this.decoration,
        decorationColor: decorationColor ?? this.decorationColor,
        decorationStyle: decorationStyle ?? this.decorationStyle,
        decorationThickness: decorationThickness ?? this.decorationThickness,
        debugLabel: debugLabel ?? this.debugLabel,
        fontFamily: fontFamily ?? this.fontFamily,
        fontFamilyFallback: fontFamilyFallback ?? this.fontFamilyFallback,
        overflow: overflow ?? this.overflow,
        package: package,
      );
}

class FontWeightNames {
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight normal = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight thick = FontWeight.w900;
}
//extension FontWeightExtension on FontWeight {
//  static const FontWeight thin = FontWeight.w100;
//  static const FontWeight extraLight = FontWeight.w200;
//  static const FontWeight light = FontWeight.w300;
//  static const FontWeight regular = FontWeight.w400;
//  static const FontWeight medium = FontWeight.w500;
//  static const FontWeight semiBold = FontWeight.w600;
//  static const FontWeight extraBold = FontWeight.w800;
//  static const FontWeight thick = FontWeight.w900;
//}
// https://stackoverflow.com/questions/70598085/extension-method-on-a-class-without-a-constructor-in-dart
// https://github.com/dart-lang/language/issues/723