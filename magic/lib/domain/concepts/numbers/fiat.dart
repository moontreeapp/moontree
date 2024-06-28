import 'package:magic/domain/concepts/numbers/coin.dart';
import 'package:magic/domain/utils/extensions/double.dart';
import 'package:magic/domain/utils/extensions/int.dart';

class Fiat {
  final double value;
  final bool rated;

  const Fiat._(this.value, {this.rated = true});
  const Fiat.empty()
      : value = 0,
        rated = false;

  factory Fiat(double value, {bool rated = true}) {
    return Fiat._(value, rated: rated);
  }
  factory Fiat.fromCoin(Coin coin, double coinPrice) => coin.toFiat(coinPrice);

  Fiat operator +(Fiat other) => Fiat._(value + other.value);

  bool isEmpty() => !rated;

  Coin toCoin(double? coinPrice) {
    if (coinPrice == null) {
      return const Coin.empty();
    }
    return Coin.fromDouble(value / coinPrice);
  }

  @override
  String toString() => isEmpty() ? '-' : value.toFiatCommaString();
  String simplified() => isEmpty() ? '\$-' : '\$${value.simplified()}';
  String humanString() => isEmpty() ? '\$-' : '\$${value.toFiatCommaString()}';

  String get head => isEmpty()
      ? '-'
      : int.parse(value.toString().split('.').first).toCommaString();
  String get tail {
    if (isEmpty()) {
      return '-';
    }
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
