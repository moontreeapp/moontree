import 'package:magic/domain/concepts/numbers/coin.dart';
import 'package:magic/domain/utils/extensions/int.dart';

const satsPerCoin = 100000000; // 1.00000000
const maxCoinPerChain = 21000000000;

/// an object representing a full quantity (coin and sats) as one big integer
class Sats {
  final int value;
  final bool isEmpty;

  const Sats._(this.value, {this.isEmpty = false});

  const Sats.empty()
      : value = 0,
        isEmpty = true;

  factory Sats(int value, {bool isEmpty = false}) {
    if (value < 0 || value > maxCoinPerChain * satsPerCoin) {
      throw ArgumentError(
          'Value must be between 0 and ${maxCoinPerChain * satsPerCoin}, inclusive.');
    }
    return Sats._(value, isEmpty: isEmpty);
  }
  factory Sats.fromCoin(Coin coin) => coin.toSats();

  Sats operator +(Sats other) => Sats._(value + other.value);

  Coin toCoin() => Coin.fromSats(this);

  // Sats shouldn't be separated by commas, so we don't get confused.
  String humanString() => value.toString(); //.toCommaString();
  String simplified() => value.simplified();
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
