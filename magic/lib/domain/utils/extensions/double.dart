import 'package:intl/intl.dart';
import 'package:magic/domain/concepts/numbers/sats.dart';

extension DoubleReadableNumericExtension on double {
  String toCommaString() =>
      NumberFormat('#,##0.########', 'en_US').format(this);
  String toSpacedCommaString() {
    String formatted = toCommaString();
    int decimalIndex = formatted.indexOf('.');
    //if (decimalIndex != -1 && formatted.length > decimalIndex + 6) {
    //  formatted =
    //      '${formatted.substring(0, decimalIndex + 6)} ${formatted.substring(decimalIndex + 6)}';
    //}
    if (decimalIndex != -1 && formatted.length > decimalIndex + 3) {
      formatted =
          '${formatted.substring(0, decimalIndex + 3)} ${formatted.substring(decimalIndex + 3)}';
    }
    return formatted;
  }

  String toFiatCommaString() => NumberFormat('#,##0.##', 'en_US').format(this);
  double roundToTenth() => (this * 10).round() / 10;
  double roundToHundredth() => (this * 100).round() / 100;
  String simplified() {
    if (this == 0.0) {
      return '0';
    }
    if (this < 1) {
      //if (this == roundToTenth()) {
      //  return '${roundToTenth()}';
      //}
      //return '${roundToTenth()}*';
      return '${roundToHundredth()}';
    }
    if (this < 100) {
      //if (this == toInt()) {
      //  return '${toInt()}';
      //}
      //return '~${toInt()}';

      return '${toInt()}';
    }
    if (this < 1000) {
      //if (this == toInt()) {
      //  return '${toInt()}';
      //}
      //return '${toInt()}.';
      return '${toInt()}';
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

  BigInt toSatsInt() => BigInt.from(this * satsPerCoin);
}
