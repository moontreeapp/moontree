// ignore_for_file: avoid_classes_with_only__members, avoid_classes_with_only_static_members
import 'package:flutter/material.dart';

class AppColors {
  static ColorScheme colorScheme = const ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.transparent,
      error: error,
      onError: Colors.white,
      background: background,
      onBackground: Colors.transparent,
      surface: Colors.white,
      onSurface: Colors.transparent);

  static const Color error = Color(0xFFEF5350);
  static const Color success = Color(0xFF66BB6A);
  static const Color primary50 = Color(0xFFE8EAF6);
  static const Color primary38 = Color(0xFFC1C7E7);
  static const Color primary60 = Color(0xFF9DA6D9);
  static const Color primary100 = Color(0xFFC5CAE9);
  static const Color primary190 = Color(0xFF9DA6D9); // guess
  static const Color primary200 = Color(0xFF9FA8DA);
  static const Color primary300 = Color(0xFF7986CB);
  static const Color primary400 = Color(0xFF5C6BC0);
  static const Color primary400b12 = Color(0xFF515EA9); // + 12 black opacity
  static const Color primary500 = Color(0xFF3F51B5);
  static const Color primary600 = Color(0xFF3949AB);
  static const Color primary700 = Color(0xFF303F9F);
  static const Color primary800 = Color(0xFF283593);
  static const Color primary900 = Color(0xFF1A237E);
  static const Color primaryDisabled = primary60;
  static const Color primary = primary400;
  static const Color background = primary;
  static const Color primaryDark = primary400b12;
  static const Color secondary = success;
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

  static const List<Color> identicons = <Color>[
    error,
    success,
    Color(0xFFEC407A),
    Color(0xFFAB47BC),
    Color(0xFF7E57C2),
    Color(0xFF42A5F5),
    Color(0xFF29B6F6),
    Color(0xFF26C6DA),
    Color(0xFF26A69A),
    Color(0xFF9CCC65),
    Color(0xFFD4E157),
    Color(0xFFFFEE58),
    Color(0xFFFFCA28),
    Color(0xFFFFA726),
    Color(0xFFFF7043),
  ];

  // not defined in figma:
  static const Color divider = black12;
  static const Color disabled = black38;
  static const Color androidSystemBar = Colors.black;
  static const Color androidNavigationBar = Colors.black;

  /** needed?

  static const Color textFieldBackground = Color(0xFFE5E5E5);
  //static const Color success = Color(0xFF00F57E);
  static const Color blue400 = Color(0xFF369DFF);
  static const Color blue60 = Color(0xFF86C4FF);
  static const Color blue38 = Color(0xFFB3DAFF);
  static const Color blue8 = Color(0xFFEFF7FF);
  static const Color blue3 = Color(0xFFF9FCFF);
  static const Color buttonTab = Color(0xFF9E9E9E);
  static const Color buttonTabs = Color(0xFFF5F5F5);
  static const Color offTransparent = Color(0x01000000);
  static const Color errorlight = Color(0xFFFF9390);
  static const Color lightGreen = Color(0xFF9CCC65);
  static const Color lime = Color(0xFFD4E157);
  static const Color yellow = Color(0xFFFFEE58);
  static const Color snackBar = Color(0xFF212121);
  static const Color logoGreen = Color(0xFF94DF3F);
  static const Color logoBlue = Color(0xFF54A3E3);
  // Colors.white.withAlpha(12) // .04*255 = 10
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
  */
}
