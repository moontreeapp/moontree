import 'package:intl/intl.dart';

extension IntReadableNumericExtension on int {
  String toCommaString() => NumberFormat('#,##0', 'en_US').format(this);
  String toSpacedString() {
    String x = padWithZeros();
    if (x.length >= 3) {
      return '${x.substring(0, 2)} ${x.substring(2)}';
    }
    return x;
  }

  String padWithZeros([int number = 8]) => toString().padLeft(number, '0');
  String simplified() {
    if (this < 1000) {
      return '$this';
    }
    if (this < 1000000) {
      return '${(this / 1000).toStringAsFixed(0)}k';
    }
    if (this < 1000000000) {
      return '${(this / 1000000).toStringAsFixed(0)}m';
    }
    if (this < 1000000000000) {
      return '${(this / 1000000000).toStringAsFixed(0)}b';
    }
    if (this < 1000000000000000) {
      return '${(this / 1000000000000).toStringAsFixed(0)}t';
    }
    if (this < 1000000000000000000) {
      return '${(this / 1000000000000000).toStringAsFixed(0)}q';
    }
    return '∞';
  }
}
