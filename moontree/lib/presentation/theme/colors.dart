// ignore_for_file: avoid_classes_with_only__members, avoid_classes_with_only_static_members
import 'package:flutter/material.dart';

class AppColors {
  static ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.transparent,
      error: error,
      onError: Colors.white,
      background: primary,
      onBackground: Colors.transparent,
      surface: Colors.white,
      onSurface: Colors.transparent);

  static const Color primary3 = Color(0xFFFFFCF8);
  static const Color primary8 = Color(0xFFFFF8EE);
  static const Color primary38 = Color(0xFFFFDEAD);
  static const Color primary50 = Color(0xFFFFF3E0);
  static const Color primary60 = Color(0xFFFFCB7D);
  static const Color primary100 = Color(0xFFFFE0B2);
  static const Color primary200 = Color(0xFFFFCD80);
  static const Color primary300 = Color(0xFFFFB84D);
  static const Color primary400 = Color(0xFFFFA826);
  static const Color primary500 = Color(0xFFFF9900);
  static const Color primary600 = Color(0xFFFB8D00);
  static const Color primary700 = Color(0xFFF57D00);
  static const Color primary800 = Color(0xFFEF6D00);
  static const Color primary900 = Color(0xFFE65300);
  static const Color primaryDisabled = primary38;
  static const Color textFieldBackground = Color(0xFFE5E5E5);
  static const Color primaryStart = Color(0xFFFF7F00); // linear gradient
  static const Color primaryEnd = Color(0xFFFFA726); // linear gradient
  static const Color error = Color(0xFFFF3C26);
  static const Color signin = Color(0xFFFF9633);
  //static const Color success = Color(0xFF00F57E);
  static const Color success = Color(0xFF3CB371);
  static const Color blue400 = Color(0xFF369DFF);
  static const Color blue60 = Color(0xFF86C4FF);
  static const Color blue38 = Color(0xFFB3DAFF);
  static const Color blue8 = Color(0xFFEFF7FF);
  static const Color blue3 = Color(0xFFF9FCFF);
  static const Color yellow = Color(0xFFFFEB3B);
  static const Color primary = primary400;
  static const Color secondary = yellow;
  static const Color buttonTab = Color(0xFF9E9E9E);
  static const Color buttonTabs = Color(0xFFF5F5F5);

  static const Color offTransparent = Color(0x01000000);
  static const Color profileBackground = Color(0xFFF0F0F0);
  static const Color background = white;

  // Colors.white.withAlpha(12) // .04*255 = 10
  static const Color white4 = Color(0x0AFFFFFF);
  static const Color white12 = Color(0x1FFFFFFF);
  static const Color white24 = Color(0x3DFFFFFF);
  static const Color white38 = Color(0x61FFFFFF);
  static const Color white60 = Color(0x99FFFFFF);
  static const Color white87 = Color(0xDEFFFFFF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black4 = Color(0x0A000000);
  static const Color black6 = Color(0x0F000000);
  static const Color black12 = Color(0x1F000000);
  static const Color black24 = Color(0x3D000000);
  static const Color black38 = Color(0x61000000);
  static const Color black60 = Color(0x99000000);
  static const Color black87 = Color(0xDE000000);
  static const Color black = Color(0xFF000000);
  static const Color divider = black12;
  static const Color disabled = black38;
  static const Color offBlack = black87;
  static const Color offWhite = white87;

  static const List<Color> whites = <Color>[
    white12,
    white24,
    white38,
    white60,
    white87,
    white,
  ];

  static const List<Color> blacks = <Color>[
    black12,
    black24,
    black38,
    black60,
    black87,
    black,
  ];

  static const List<int> lightPrimaryNumbers = <int>[38, 60];
  static const List<int> whiteNumbers = <int>[12, 38, 60, 87, 100];
  static const List<int> blackNumbers = <int>[12, 38, 60, 87, 100];

  static const Color androidSystemBar =
      Colors.black; // (0xFF3F7442); //primary.withOpacity(1 - .12);
  static const Color androidNavigationBar =
      Colors.black; //(0xFF3F7442); //primary.withOpacity(1 - .60);
  //Color(0xFF384277); //primary.withOpacity(1 - .38);
  //static Color scrim = black.withOpacity(1 - .38);
  static const Color scrim = black24;
  static Color scrimLight = white.withOpacity(1 - .12);

  static List<int> tooClose(int index) =>
      <int, List<int>>{
        1: <int>[15],
        5: <int>[8, 6],
        6: <int>[7, 9],
        7: <int>[9, 10],
        8: <int>[5],
        9: <int>[5, 6, 7],
        10: <int>[7],
        13: <int>[11],
      }[index] ??
      <int>[];

  static List<int> tooClash(int index) =>
      <int, List<int>>{
        0: <int>[5, 6, 8],
        5: <int>[0, 1, 15],
        6: <int>[0, 1, 14, 15],
        7: <int>[0, 1, 14, 15],
        8: <int>[0, 1, 15],
        9: <int>[15],
        10: <int>[14],
        14: <int>[6, 7],
        15: <int>[5, 6, 7, 8],
      }[index] ??
      <int>[];

  static List<int> rgb(Color color) =>
      <int>[color.red, color.green, color.blue];
}
