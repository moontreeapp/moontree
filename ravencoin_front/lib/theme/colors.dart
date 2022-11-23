import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:moontree_utils/src/zips.dart' show zipMap;

class AppColors {
  static List<Color> get palette => [
        error,
        const Color(0xFFEC407A),
        const Color(0xFFAB47BC),
        const Color(0xFF7E57C2),
        primary,
        const Color(0xFF42A5F5),
        const Color(0xFF29B6F6),
        const Color(0xFF26C6DA),
        const Color(0xFF26A69A),
        success,
        lightGreen,
        lime,
        yellow,
        const Color(0xFFFFCA28),
        const Color(0xFFFFA726),
        const Color(0xFFFF7043),
      ];

  static const error = const Color(0xFFEF5350);
  static const success = const Color(0xFF66BB6A);
  static const lightGreen = const Color(0xFF9CCC65);
  static const primary = const Color(0xFF5C6BC0);
  static const lime = const Color(0xFFD4E157);
  static const yellow = const Color(0xFFFFEE58);
  static const primaryDisabled = const Color(0xFFC1C7E7);
  static const snackBar = const Color(0xFF212121);
  static const logoGreen = const Color(0xFF94DF3F);
  static const logoBlue = const Color(0xFF54A3E3);

  // .12 Colors.white.withAlpha(12)
  static const white12 = const Color(0x1FFFFFFF);
  static const white38 = const Color(0x61FFFFFF);
  static const white60 = const Color(0x99FFFFFF);
  static const white87 = const Color(0xDEFFFFFF);
  static const white = const Color(0xFFFFFFFF);
  static const black12 = const Color(0x1F000000);
  static const black38 = const Color(0x61000000);
  static const black60 = const Color(0x99000000);
  static const black87 = const Color(0xDE000000);
  static const black = const Color(0xFF000000);
  static const divider = black12;
  static const disabled = black38;
  static const offBlack = black87;
  static const offWhite = white87;

  static List<Color> get whites => [
        white12,
        white38,
        white60,
        white87,
        white,
      ];

  static List<Color> get blacks => [
        black12,
        black38,
        black60,
        black87,
        black,
      ];

  static List<Color> get primaries => [
        const Color(0xFFE8EAF6),
        const Color(0xFFC5CAE9),
        const Color(0xFF9FA8DA),
        const Color(0xFF7986CB),
        primary,
        const Color(0xFF3F51B5),
        const Color(0xFF3949AB),
        const Color(0xFF303F9F),
        const Color(0xFF283593),
        const Color(0xFF1A237E),
      ];

  static List<Color> get lightPrimaries => [
        primaryDisabled,
        const Color(0xFF9DA6D9),
      ];

  static List<int> get primaryNumbers =>
      [50, 100, 200, 300, 400, 500, 600, 700, 800, 900];

  static List<int> get lightPrimaryNumbers => [38, 60];
  static List<int> get whiteNumbers => [12, 38, 60, 87, 100];
  static List<int> get blackNumbers => [12, 38, 60, 87, 100];

  static Color get androidSystemBar => primary.withOpacity(1 - .12);
  static Color get scrim => black.withOpacity(1 - .38);

  List<Color> get backgroundColors => palette
      .where((Color color) => ![lime, yellow, primary].contains(color))
      .toList();

  List<Color> foregroundColors(Color background) {
    var index = backgroundColors.indexOf(background);
    var allIndex = palette.indexOf(background);
    var length = backgroundColors.length;
    var ret = <Color>[];
    if (index == 0) {
      ret = palette.sublist(2, palette.length - 1);
    } else if (index == length - 1) {
      ret = palette.sublist(1, palette.length - 2);
    } else {
      ret = palette.where((Color color) {
        if (![palette[index - 1], palette[index], palette[index + 1]]
            .contains(color)) {
          return true;
        }
        return false;
      }).toList();
    }
    return ret
        .where((Color color) =>
            color != primary && !noGood(allIndex).contains(color))
        .toList();
  }

  List<int> tooClose(int index) =>
      {
        1: [15],
        5: [8, 6],
        6: [7, 9],
        7: [9, 10],
        8: [5],
        9: [5, 6, 7],
        10: [7],
        13: [11],
      }[index] ??
      <int>[];

  List<int> tooClash(int index) =>
      {
        0: [5, 6, 8],
        5: [0, 1, 15],
        6: [0, 1, 14, 15],
        7: [0, 1, 14, 15],
        8: [0, 1, 15],
        9: [15],
        10: [14],
        14: [6, 7],
        15: [5, 6, 7, 8],
      }[index] ??
      <int>[];

  Set<Color> noGood(int index) =>
      {for (var i in tooClose(index) + tooClash(index)) palette[i]};

  Map<int, Color> get primaryMap =>
      zipMap(primaryNumbers + lightPrimaryNumbers, primaries + lightPrimaries)
          as Map<int, Color>;

  Color backgroundColor(String name) =>
      backgroundColors[name.codeUnits.sum % backgroundColors.length];

  Color foregroundColor(String name, {Color? backColor}) {
    var foreColors = foregroundColors(backColor ?? backgroundColor(name));
    return foreColors[name.codeUnits.sum % foreColors.length];
  }

  static List<int> RGB(Color color) => [color.red, color.green, color.blue];
}
