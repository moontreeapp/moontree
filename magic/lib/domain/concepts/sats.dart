import 'package:decimal/decimal.dart';
import 'package:magic/domain/concepts/coin.dart';
import 'package:magic/domain/extensions/decimal.dart';
import 'package:magic/domain/extensions/double.dart';
import 'package:magic/domain/extensions/int.dart';

const satsPerCoin = 100000000;
Decimal satsPerCoinDec = Decimal.fromInt(100000000);

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
    return Sats._((coin.value.toDouble() * satsPerCoin).round());
    // gave this problem:
    //I/flutter ( 4206): display.sats.value: 2000000000009999872
    //I/flutter ( 4206): display.coin.value: 20000000000.1

    // Convert coin value to a string
    var valueStr = coin.value.toCommaString();
    print('valueStr: $valueStr');
    // Find the decimal point position

    int decimalIndex = valueStr.indexOf('.');
    // Remove the decimal point by creating a new string
    String newStr = valueStr.substring(0, decimalIndex) +
        valueStr.substring(decimalIndex + 1);

    print('newStr: $newStr');
    // Convert the string to an integer
    return Sats._(int.parse(newStr));
  }
  const Sats.empty()
      : value = 0,
        isEmpty = true;
  Sats operator +(Sats other) => Sats._(value + other.value);
  Coin get toCoin => Coin((value.toDecimal() / satsPerCoinDec).toDecimal());
  // Sats shouldn't be separated by commas, so we don't get confused.
  String humanString() => value.toString(); //.toCommaString();
  String simplified() => value.simplified();
}

//class Coin {
//  final double value;
//  const Coin._(this.value);
//  factory Coin(double value) {
//    if (value < 0 || value > 21000000000) {
//      throw ArgumentError(
//          'Value must be between 0 and 21000000000, inclusive.');
//    }
//    return Coin._(value);
//  }
//  factory Coin.fromSats(Sats sat) {
//    return Coin._(sat.value / satsPerCoin);
//  }
//  Coin operator +(Coin other) => Coin._(value + other.value);
//  Sats get toSats => Sats((value * satsPerCoin).round());
//  Fiat toFiat(double coinPrice) => Fiat(value * coinPrice);
//  String humanString() => value.toSpacedCommaString();
//  String simplified() => value.simplified();
//  String whole() => humanString().split('.').first;
//  String part() => ['', '0', humanString().split('.').first]
//          .contains(humanString().split('.').last)
//      ? ''
//      : '.${humanString().split('.').last}';
//}

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
