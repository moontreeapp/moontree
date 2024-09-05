// ignore_for_file: avoid_print

import 'package:collection/collection.dart';

enum LogColor {
  red,
  green,
  yellow,
  blue,
  magenta,
  cyan,
  reset;

  String colorize(String msg) {
    // ANSI escape codes for colors
    const String reset = '\x1B[0m';
    const String red = '\x1B[31m';
    const String green = '\x1B[32m';
    const String yellow = '\x1B[33m';
    const String blue = '\x1B[34m';
    const String magenta = '\x1B[35m';
    const String cyan = '\x1B[36m';

    switch (this) {
      case LogColor.red:
        return '$red$msg$reset';
      case LogColor.green:
        return '$green$msg$reset';
      case LogColor.yellow:
        return '$yellow$msg$reset';
      case LogColor.blue:
        return '$blue$msg$reset';
      case LogColor.magenta:
        return '$magenta$msg$reset';
      case LogColor.cyan:
        return '$cyan$msg$reset';
      case LogColor.reset:
        return '$reset$msg$reset';
      default:
        return '$reset$msg$reset';
    }
  }
}

void see(
  dynamic message, [
  dynamic msg0,
  LogColor color = LogColor.cyan,
  dynamic msg1,
  dynamic msg2,
  dynamic msg3,
  dynamic msg4,
  dynamic msg5,
  dynamic msg6,
  dynamic msg7,
  dynamic msg8,
  dynamic msg9,
]) {
  final msg = [
    message,
    msg0,
    msg1,
    msg2,
    msg3,
    msg4,
    msg5,
    msg6,
    msg7,
    msg8,
    msg9
  ].whereNotNull().join(' ');
  print(color.colorize(msg));
}
