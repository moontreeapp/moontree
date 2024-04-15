import 'package:intl/intl.dart';

extension DoubleReadableNumericExtension on double {
  String toCommaString() =>
      NumberFormat('#,##0.########', 'en_US').format(this);
  String toFiatCommaString() => NumberFormat('#,##0.##', 'en_US').format(this);
  double roundToTenth() => (this * 10).ceil() / 10;
  double roundToHundredth() => (this * 100).ceil() / 100;
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
}

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

const satsPerCoin = 100000000;

class Sats {
  final int value;
  final bool isEmpty;
  const Sats._(this.value, {this.isEmpty = false});
  factory Sats(int value, {bool isEmpty = false}) {
    if (value < 0 || value > 21000000000 * satsPerCoin) {
      throw ArgumentError(
          'Value must be between 0 and 2100000000000000000, inclusive.');
    }
    return Sats._(value, isEmpty: isEmpty);
  }
  factory Sats.fromCoin(Coin coin) {
    return Sats._((coin.value * satsPerCoin).round());
  }
  const Sats.empty()
      : value = 0,
        isEmpty = true;
  Sats operator +(Sats other) => Sats._(value + other.value);
  Coin get toCoin => Coin(value / satsPerCoin);
  // Sats shouldn't be separated by commas, so we don't get confused.
  String humanString() => value.toString(); //.toCommaString();
  String simplified() => value.simplified();
}

class Coin {
  final double value;
  const Coin._(this.value);
  factory Coin(double value) {
    if (value < 0 || value > 21000000000) {
      throw ArgumentError(
          'Value must be between 0 and 21000000000, inclusive.');
    }
    return Coin._(value);
  }
  factory Coin.fromSats(Sats sat) {
    return Coin._(sat.value / satsPerCoin);
  }
  Coin operator +(Coin other) => Coin._(value + other.value);
  Sats get toSats => Sats((value * satsPerCoin).round());
  Fiat toFiat(double coinPrice) => Fiat(value * coinPrice);
  String humanString() => value.toCommaString();
  String simplified() => value.simplified();
}

class Fiat {
  final double value;
  const Fiat._(this.value);
  factory Fiat(double value) {
    return Fiat._(value);
  }
  factory Fiat.fromCoin(Coin coin, double coinPrice) =>
      Fiat._(coin.value * coinPrice);
  const Fiat.empty() : value = 0;
  Fiat operator +(Fiat other) => Fiat._(value + other.value);
  @override
  String toString() => value.toFiatCommaString();
  String simplified() => '\$${value.simplified()}';
  String humanString() => value.toFiatCommaString();
  String get head =>
      int.parse(value.toString().split('.').first).toCommaString();
  String get tail {
    final cents = '.${value.toString().split('.').last}';
    if (cents.length == 2) {
      return '${cents}0';
    }
    if (cents.length == 3) {
      return cents;
    }
    return cents.substring(0, 3);
  }
}

class Divisibility {
  final int value;
  final bool isEmpty;
  const Divisibility._(this.value, {this.isEmpty = false});
  factory Divisibility(int value, {bool isEmpty = false}) {
    if (value < 0 || value > 8) {
      throw ArgumentError('Value must be between 0 and 8, inclusive.');
    }
    return Divisibility._(value, isEmpty: isEmpty);
  }
  const Divisibility.empty()
      : value = 0,
        isEmpty = true;
}
