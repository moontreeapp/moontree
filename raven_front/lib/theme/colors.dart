import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:raven_front/utils/zips.dart';

class AppColors {
  static List<Color> get colors => [
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
        const Color(0xFF9CCC65),
        lime,
        yellow,
        const Color(0xFFFFCA28),
        const Color(0xFFFFA726),
        const Color(0xFFFF7043),
      ];

  static Color get error => const Color(0xFFEF5350);
  static Color get success => const Color(0xFF66BB6A);
  static Color get primary => const Color(0x5C6BC0);
  static Color get lime => const Color(0xFFD4E157);
  static Color get yellow => const Color(0xFFFFEE58);

  static List<Color> get whites => [
        // alphas
        const Color(0x1FFFFFFF), // .12 Colors.white.withAlpha(12)
        const Color(0x61FFFFFF), // .38 Colors.white.withAlpha(38)
        const Color(0x99FFFFFF), // .60 Colors.white.withAlpha(60)
        const Color(0xDEFFFFFF), // .87 Colors.white.withAlpha(87)
        const Color(0xFFFFFFFF), // 1.0 Colors.white.withAlpha(100)
      ];

  static List<Color> get blacks => [
        // alphas
        const Color(0x1F000000), // .12
        const Color(0x61000000), // .38
        const Color(0x99000000), // .60
        const Color(0xDE000000), // .87
        const Color(0xFF000000), // 1.0
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
        const Color(0xFF9DA6D9),
        const Color(0xFFC1C7E7),
      ];

  static List<int> get primaryNames =>
      [50, 100, 200, 300, 400, 500, 600, 700, 800, 900];

  static List<int> get lightPrimaryNames => [60, 38];

  List<Color> get backgroundColors => colors
      .where((Color color) => ![lime, yellow, primary].contains(color))
      .toList();

  List<Color> foregroundColors(Color background) {
    var index = backgroundColors.indexOf(background);
    var allIndex = colors.indexOf(background);
    var length = backgroundColors.length;
    var ret = <Color>[];
    if (index == 0) {
      ret = colors.sublist(2, colors.length - 1);
    } else if (index == length - 1) {
      ret = colors.sublist(1, colors.length - 2);
    } else {
      ret = colors.where((Color color) {
        if (![colors[index - 1], colors[index], colors[index + 1]]
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
      {for (var i in tooClose(index) + tooClash(index)) colors[i]};

  Map<int, Color> get primaryMap =>
      zipMap(primaryNames + lightPrimaryNames, primaries + lightPrimaries)
          as Map<int, Color>;

  Color backgroundColor(String name) =>
      backgroundColors[name.codeUnits.sum % backgroundColors.length];

  Color foregroundColor(String name, {Color? backColor}) {
    var foreColors = foregroundColors(backColor ?? backgroundColor(name));
    return foreColors[name.codeUnits.sum % foreColors.length];
  }

  static List<int> RGB(Color color) => [color.red, color.green, color.blue];

/* to view all valid combinations (plus too close and clashing) all for testing
/// needs flutter
ListView(
  children: [
    for (var b in [0, 1, 2, 3, 5, 6, 7, 8, 9, 10, 13, 14, 15])
      for (var f in [
        0,
        1,
        2,
        3,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15
      ])
        if (b != f &&
            b != f - 1 &&
            b != f + 1 &&
            !(b == 0 && f == 15) &&
            !(b == 15 && f == 0))
          ListTile(
            leading: components.icons.assetAvatar('',
                foreground: AppColors.colors[f],
                background: AppColors.colors[b]),
            title: Text(
                'background index: $b foreground index: $f'),
            subtitle: Text(
                'background: ${AppColors.colors[b]} foreground: ${AppColors.colors[f]}'),
          )
])
*/
/* possible combos
ListView(
  children: [
  for (var b in AppColors().backgroundColors)
    for (var f in AppColors().foregroundColors(b))
      ListTile(
        leading: components.icons
            .assetAvatar('', foreground: f, background: b),
        title:
            Text('bc: $b  b: ${AppColors.colors.indexOf(b)}'),
        subtitle:
            Text('fc: $f  f: ${AppColors.colors.indexOf(f)}'),
      )
])
*/

}
