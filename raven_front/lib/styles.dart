export 'package:raven_mobile/components/styles/text.dart';
export 'package:raven_mobile/components/styles/colors.dart';
export 'package:raven_mobile/components/styles/icons.dart';
export 'package:raven_mobile/components/styles/buttons.dart';

import 'package:flutter/material.dart';

extension ValueColorExtension on ThemeData {
  Color? get good => this.brightness == Brightness.light
      ? Colors.green.shade800
      : Colors.green.shade400;
  Color? get bad => this.brightness == Brightness.light
      ? Colors.red.shade900
      : Colors.red.shade500;
  Color? get fine => this.brightness == Brightness.light
      ? Colors.grey.shade900
      : Colors.grey.shade400;
}
