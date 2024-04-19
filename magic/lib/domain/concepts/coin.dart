import 'package:decimal/decimal.dart';
import 'package:magic/domain/concepts/fiat.dart';
import 'package:magic/domain/concepts/sats.dart';
import 'package:magic/domain/extensions/double.dart';
import 'package:magic/domain/extensions/int.dart';

class Coin {
  final Decimal value;
  const Coin._(this.value);

  factory Coin(Decimal value) {
    if (value < Decimal.zero || value > Decimal.parse('21000000000')) {
      throw ArgumentError(
          'Value must be between 0 and 21000000000, inclusive.');
    }
    return Coin._(value);
  }

  factory Coin.fromSats(Sats sat) {
    return Coin._((Decimal.fromInt(sat.value) / satsPerCoinDec).toDecimal());
  }
  factory Coin.fromDouble(double d) {
    return Coin._(
        (Decimal.fromBigInt(d.toSatsInt()) / satsPerCoinDec).toDecimal());
  }

  factory Coin.fromInt(int d) {
    return Coin._(Decimal.fromInt(d));
  }

  Coin operator +(Coin other) => Coin._(value + other.value);

  Sats get toSats => Sats((value * satsPerCoinDec).toBigInt().toInt());

  Fiat toFiat(double coinPrice) {
    // Convert Decimal to double for operations not supported by Decimal directly
    return Fiat(value.toDouble() * coinPrice);
  }

  String humanString() {
    return value
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ',');
  }

  String simplified() {
    // Implement or adapt an existing method to handle Decimal, depending on requirements
    return value.toStringAsFixed(2).replaceAll('.00', '');
  }

  String whole() => humanString().split('.').first;

  String part() {
    String decimalPart = humanString().split('.').last;
    return ['', '0', '00'].contains(decimalPart) ? '' : '.$decimalPart';
  }
}
