import 'package:magic/domain/concepts/coin.dart';
import 'package:magic/domain/extensions/double.dart';
import 'package:magic/domain/extensions/int.dart';

class Fiat {
  final double value;
  final bool rated;
  const Fiat._(this.value, {this.rated = true});
  factory Fiat(double value, {bool rated = true}) {
    return Fiat._(value, rated: rated);
  }
  factory Fiat.fromCoin(Coin coin, double coinPrice) =>
      Fiat._(coin.value.toDouble() * coinPrice);
  const Fiat.empty()
      : value = 0,
        rated = false;
  Fiat operator +(Fiat other) => Fiat._(value + other.value);
  bool isEmpty() => !rated;
  @override
  String toString() => isEmpty() ? '-' : value.toFiatCommaString();
  String simplified() => isEmpty() ? '-' : '\$${value.simplified()}';
  String humanString() => isEmpty() ? '-' : value.toFiatCommaString();
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
