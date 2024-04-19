import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
//import 'package:rational/rational.dart';

extension DecimalReadableNumericExtension on Decimal {
  String toCommaString() =>
      NumberFormat('#,##0.########', 'en_US').format(toDouble());

  String toSpacedCommaString() {
    String formatted = toCommaString();
    int decimalIndex = formatted.indexOf('.');
    if (decimalIndex != -1 && formatted.length > decimalIndex + 3) {
      formatted =
          '${formatted.substring(0, decimalIndex + 3)} ${formatted.substring(decimalIndex + 3)}';
    }
    return formatted;
  }

  String toFiatCommaString() =>
      NumberFormat('#,##0.##', 'en_US').format(toDouble());

  Decimal roundToTenth() =>
      ((this * Decimal.fromInt(10)).ceil() / Decimal.fromInt(10)).toDecimal();

  Decimal roundToHundredth() =>
      ((this * Decimal.fromInt(100)).ceil() / Decimal.fromInt(100)).toDecimal();

  String simplified() {
    if (this == Decimal.zero) {
      return '0';
    }
    if (this < Decimal.one) {
      return '${roundToHundredth()}';
    }
    if (this < Decimal.fromInt(100)) {
      return '${toInt()}';
    }
    if (this < Decimal.fromInt(1000)) {
      return '${toInt()}';
    }
    if (this < Decimal.parse('1000000')) {
      return '${(this / Decimal.fromInt(1000)).toDecimal().toInt().toStringAsFixed(0)}k';
    }
    if (this < Decimal.parse('1000000000')) {
      return '${(this / Decimal.parse('1000000')).toDecimal().toInt().toStringAsFixed(0)}m';
    }
    if (this < Decimal.parse('1000000000000')) {
      return '${(this / Decimal.parse('1000000000')).toDecimal().toInt().toStringAsFixed(0)}b';
    }
    if (this < Decimal.parse('1000000000000000')) {
      return '${(this / Decimal.parse('1000000000000')).toDecimal().toInt().toStringAsFixed(0)}t';
    }
    if (this < Decimal.parse('1000000000000000000')) {
      return '${(this / Decimal.parse('1000000000000000')).toDecimal().toInt().toStringAsFixed(0)}q';
    }
    return '∞';
  }

  int toInt() => toBigInt().toInt();
}
