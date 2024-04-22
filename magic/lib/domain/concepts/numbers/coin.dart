import 'package:magic/domain/concepts/numbers/fiat.dart';
import 'package:magic/domain/concepts/numbers/sats.dart';
import 'package:magic/domain/utils/extensions/int.dart';

class Coin {
  final int coin;
  final int sats;
  final bool isEmpty;

  const Coin._({this.coin = 0, this.sats = 0, this.isEmpty = false});

  const Coin.empty()
      : coin = 0,
        sats = 0,
        isEmpty = true;

  factory Coin({int? coin, int? sats, bool isEmpty = false}) {
    coin = coin ?? 0;
    sats = sats ?? 0;
    if (coin < 0 || coin > maxCoinPerChain) {
      throw ArgumentError(
          'coin must be between 0 and $maxCoinPerChain, inclusive.');
    }
    if (sats < 0 || sats >= satsPerCoin) {
      throw ArgumentError(
          'sats must be between 0 and ${satsPerCoin - 1}, inclusive.');
    }
    return Coin._(coin: coin, sats: sats, isEmpty: isEmpty);
  }

  /// here we assume this value is a full amount in sats
  factory Coin.fromInt(int value) {
    int coin = (value / satsPerCoin).floor();
    return Coin._(
      coin: coin,
      sats: value - (coin * satsPerCoin),
    );
  }
  factory Coin.fromSats(Sats sats) {
    return Coin.fromInt(sats.value);
  }
  factory Coin.fromString(String value) {
    if (value.contains('.')) {
      return Coin._(
        coin: int.tryParse(value.split('.').first.replaceAll(',', '')) ?? 0,
        sats: int.tryParse(value.split('.').last.replaceAll(' ', '')) ?? 0,
      );
    }
    return Coin._(
      coin: int.tryParse(value.split('.').first) ?? 0,
      sats: 0,
    );
  }

  Coin operator +(Coin other) => Coin._(
        coin: coin + other.coin,
        sats: sats + other.sats,
      );

  Sats toSats() => Sats((coin * satsPerCoin) + sats);
  Fiat toFiat(double coinPrice) =>
      Fiat((coin * coinPrice) + ((sats / satsPerCoin) * coinPrice));

  String humanString() => '${whole()}${part()}';

  /// 1,234.56788901 -> 1k
  String simplified() {
    if (coin < 10 && sats > 0) {
      final ret = '${coin.simplified()}.${sats.toSpacedString()}';
      if (ret.split(' ').first == '0.00') {
        return '0';
      }
      return ret.split(' ').first;
    }
    return coin.simplified();
  }

  /// 1,234.56788901
  String complicated() {
    if (coin < 10 && sats > 0) {
      final ret = '${coin.simplified()}.${sats.toSpacedString()}';
      if (ret.split(' ').first == '0.00') {
        return '0';
      }
      return ret.split(' ').first;
    }
    return coin.simplified();
  }

  String whole() => coin.toCommaString();
  String part({bool zeros = false}) =>
      zeros || sats > 0 ? '.${sats.padWithZeros()}' : '';
  String partOne() => '.${sats.padWithZeros().substring(0, 2)}';
  String partTwo() => sats.padWithZeros().substring(2, 5);
  String partThree() => sats.padWithZeros().substring(5, 8);
  String entire() => '${whole()}${part(zeros: true)}';
  String beginning() => entire().substring(0, entire().length - 6);
  String ending() => entire().substring(entire().length - 6);
}
