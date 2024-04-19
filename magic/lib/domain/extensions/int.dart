import 'package:intl/intl.dart';

extension IntReadableNumericExtension on int {
  String toCommaString() => NumberFormat('#,##0', 'en_US').format(this);
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
