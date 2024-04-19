import 'package:magic/domain/concepts/numbers/fiat.dart';
import 'package:magic/domain/concepts/numbers/sats.dart';
import 'package:magic/domain/utils/extensions/int.dart';
import 'package:magic/domain/utils/extensions/string.dart';

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

  String humanString() => '${coin.toCommaString()}${part()}';
  String simplified() {
    if (coin < 10 && sats > 0) {
      return '${coin.simplified()}.$sats';
    }
    return coin.simplified();
  }

  String whole() => coin.toCommaString();
  String part() => '.${sats > 0 ? sats.toSpacedString() : ''}';
}
