import 'package:intl/intl.dart';

extension DoubleReadableNumericExtension on double {
  String toCommaString() =>
      NumberFormat('#,##0.########', 'en_US').format(this);
}

extension IntReadableNumericExtension on int {
  String toCommaString() => NumberFormat('#,##0' 'en_US').format(this);
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
  String humanString() => value.toCommaString();
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
