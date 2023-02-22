// ignore_for_file: avoid_classes_with_only__members, avoid_classes_with_only_static_members
import 'package:collection/collection.dart' show IterableIntegerExtension;
import 'package:flutter/material.dart';
import 'package:moontree_utils/moontree_utils.dart' show zipMap;

class AppColors {
  static List<Color> get palette => <Color>[
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

  static const Color error = Color(0xFFEF5350);
  static const Color success = Color(0xFF66BB6A);
  static const Color lightGreen = Color(0xFF9CCC65);
  static const Color primary = Color(0xFF5C6BC0);
  static const Color lime = Color(0xFFD4E157);
  static const Color yellow = Color(0xFFFFEE58);
  static const Color primaryDisabled = Color(0xFFC1C7E7);
  static const Color snackBar = Color(0xFF212121);
  static const Color logoGreen = Color(0xFF94DF3F);
  static const Color logoBlue = Color(0xFF54A3E3);

// .12 Colors.white.withAlpha(12)
  static const Color white12 = Color(0x1FFFFFFF);
  static const Color white38 = Color(0x61FFFFFF);
  static const Color white60 = Color(0x99FFFFFF);
  static const Color white87 = Color(0xDEFFFFFF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black12 = Color(0x1F000000);
  static const Color black38 = Color(0x61000000);
  static const Color black60 = Color(0x99000000);
  static const Color black87 = Color(0xDE000000);
  static const Color black = Color(0xFF000000);
  static const Color error12 = Color(0x1FEF5350);
  static const Color error38 = Color(0x61EF5350);
  static const Color error60 = Color(0x99EF5350);
  static const Color error87 = Color(0xDEEF5350);
  static Color error38o = error.withOpacity(1 - .38);
  static const Color divider = black12;
  static const Color disabled = black38;
  static const Color offBlack = black87;
  static const Color offWhite = white87;

  static const List<Color> whites = <Color>[
    white12,
    white38,
    white60,
    white87,
    white,
  ];

  static const List<Color> blacks = <Color>[
    black12,
    black38,
    black60,
    black87,
    black,
  ];

  static const List<Color> primaries = <Color>[
    Color(0xFFE8EAF6),
    Color(0xFFC5CAE9),
    Color(0xFF9FA8DA),
    Color(0xFF7986CB),
    primary,
    Color(0xFF3F51B5),
    Color(0xFF3949AB),
    Color(0xFF303F9F),
    Color(0xFF283593),
    Color(0xFF1A237E),
  ];

  static const List<Color> lightPrimaries = <Color>[
    primaryDisabled,
    Color(0xFF9DA6D9),
  ];

  static const List<int> primaryNumbers = <int>[
    50,
    100,
    200,
    300,
    400,
    500,
    600,
    700,
    800,
    900
  ];

  static const List<int> lightPrimaryNumbers = <int>[38, 60];
  static const List<int> whiteNumbers = <int>[12, 38, 60, 87, 100];
  static const List<int> blackNumbers = <int>[12, 38, 60, 87, 100];

  static const Color androidSystemBar =
      const Color(0xFF505DA9); //primary.withOpacity(1 - .12);
  static const Color androidNavigationBar =
      const Color(0xFF272B4C); //primary.withOpacity(1 - .60);
  //Color(0xFF384277); //primary.withOpacity(1 - .38);
  static Color scrim = black.withOpacity(1 - .38);
  static Color scrimLight = white.withOpacity(1 - .12);

  static List<Color> backgroundColors = palette
      .where((Color color) => !<Color>[lime, yellow, primary].contains(color))
      .toList();

  static List<Color> foregroundColors(Color background) {
    final int index = backgroundColors.indexOf(background);
    final int allIndex = palette.indexOf(background);
    final int length = backgroundColors.length;
    List<Color> ret = <Color>[];
    if (index == 0) {
      ret = palette.sublist(2, palette.length - 1);
    } else if (index == length - 1) {
      ret = palette.sublist(1, palette.length - 2);
    } else {
      ret = palette.where((Color color) {
        if (!<Color>[palette[index - 1], palette[index], palette[index + 1]]
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

  static Set<Color> noGood(int index) =>
      <Color>{for (int i in tooClose(index) + tooClash(index)) palette[i]};

  static Map<int, Color> get primaryMap =>
      zipMap(primaryNumbers + lightPrimaryNumbers, primaries + lightPrimaries)
          as Map<int, Color>;

  static Color backgroundColor(String name) =>
      backgroundColors[name.codeUnits.sum % backgroundColors.length];

  static Color foregroundColor(String name, {Color? backColor}) {
    final List<Color> foreColors =
        foregroundColors(backColor ?? backgroundColor(name));
    return foreColors[name.codeUnits.sum % foreColors.length];
  }

  static List<int> rgb(Color color) =>
      <int>[color.red, color.green, color.blue];
}
