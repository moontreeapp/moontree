import 'package:equatable/equatable.dart';
import 'package:magic/domain/concepts/numbers/fiat.dart';
import 'package:magic/domain/concepts/numbers/sats.dart';
import 'package:magic/domain/utils/extensions/int.dart';

class Coin extends Equatable {
  final int coin;
  final int sats;
  final bool isEmpty;

  const Coin._({this.coin = 0, this.sats = 0, this.isEmpty = false});

  const Coin.empty()
      : coin = 0,
        sats = 0,
        isEmpty = true;

  @override
  List<Object?> get props => [coin, sats, isEmpty];

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
    value = value.trim().replaceAll(',', '');
    if (value.contains('.')) {
      var parts = value.split('.');
      var coinPart = int.tryParse(parts.first.replaceAll(',', '')) ?? 0;
      var satPartStr = parts.last.replaceAll(' ', '');
      var satPart = int.tryParse(satPartStr) ?? 0;

      // Calculate the sats correctly
      var satMultiplier = (satPartStr.length < 8) ? (8 - satPartStr.length) : 0;
      var sats = satPart *
          (satMultiplier > 0
              ? int.parse('1'.padRight(satMultiplier + 1, '0'))
              : 1);
      sats = sats.toString().length > 8
          ? int.parse(sats.toString().substring(0, 8))
          : sats;
      return Coin._(
        coin: coinPart,
        sats: sats,
      );
    }
    return Coin._(
      coin: int.tryParse(value.split('.').first.replaceAll(',', '')) ?? 0,
      sats: 0,
    );
  }
  factory Coin.fromDouble(double amount) => Coin.fromString(amount.toString());

  Coin operator +(Coin other) => Coin._(
        coin: coin + other.coin,
        sats: sats + other.sats,
      );

  @override
  String toString() => '$coin.$sats';
  double toDouble() => double.parse('${coin.toString()}.${sats.toString()}');
  Sats toSats() => Sats((coin * satsPerCoin) + sats);
  Fiat toFiat(double? coinPrice) => coinPrice == null
      ? const Fiat.empty()
      : Fiat((coin * coinPrice) + ((sats / satsPerCoin) * coinPrice));

  String humanString() => '${whole()}${part()}';

  /// 1,234.56788901 -> 1k
  String simplified() {
    if (coin == 0 && sats == 0) {
      return '0';
    }
    if (coin == 0 && sats == 1) {
      return '$sats satoshi';
    }
    if (coin == 0 && sats < 1000000) {
      return '${sats.simplified()} sats';
    }
    if (coin == 0 && sats >= 1000000) {
      //return '0.${sats.toSpacedString().split(' ').first} (${sats.simplified()} sats)';
      return '${sats.simplified()} sats';
    }
    if (coin < 10 && sats > 0) {
      final ret = '${coin.simplified()}.${sats.toSpacedString()}';
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
  String spacedEnding() =>
      '${entire().substring(entire().length - 6, entire().length - 3)} ${entire().substring(entire().length - 3)}';
  String spacedPart({bool zeros = false}) {
    final p = part(zeros: zeros);
    if (zeros) {
      return '${p.substring(0, 3)} ${p.substring(3, 6)} ${p.substring(6)}';
    }
    if (p.length > 6) {
      return '${p.substring(0, 3)} ${p.substring(3, 6)} ${p.substring(6)}';
    }
    return p;
  }

  List<EnrichedChar> boldedPart({bool zeros = false}) {
    final p = part(zeros: zeros);
    var bolded = false;
    final ret = <EnrichedChar>[];
    for (int i = 0; i < p.length; i++) {
      if (p[i] != '0' && p[i] != '.') {
        bolded = true;
      }
      if (p[i] == '.') {
        bolded = true;
      }
      ret.add(EnrichedChar(char: p[i], bolded: bolded));
      if (p[i] == '.') {
        bolded = false;
      }
    }
    return ret;
  }
}

class EnrichedChar extends Equatable {
  final String char;
  final bool bolded;
  const EnrichedChar({required this.char, this.bolded = false});
  @override
  List<Object?> get props => [char, bolded];
}
