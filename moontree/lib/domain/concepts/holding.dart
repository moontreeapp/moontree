import 'package:equatable/equatable.dart';

const satsPerCoin = 100000000;

class Sat {
  final int value;
  final bool isEmpty;
  const Sat._(this.value, {this.isEmpty = false});
  factory Sat(int value, {bool isEmpty = false}) {
    if (value < 0 || value > 21000000000 * satsPerCoin) {
      throw ArgumentError(
          'Value must be between 0 and 2100000000000000000, inclusive.');
    }
    return Sat._(value, isEmpty: isEmpty);
  }
  factory Sat.fromCoin(Coin coin) {
    return Sat._((coin.value * satsPerCoin).round());
  }
  const Sat.empty()
      : value = 0,
        isEmpty = true;
  Sat operator +(Sat other) => Sat._(value + other.value);
  Coin get toCoin => Coin(value / satsPerCoin);
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
  factory Coin.fromSats(Sat sat) {
    return Coin._(sat.value / satsPerCoin);
  }
  Coin operator +(Coin other) => Coin._(value + other.value);
  Sat get toSats => Sat((value * satsPerCoin).round());
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

class Holding extends Equatable {
  final String name;
  final String symbol;
  final HoldingMetadata metadata;
  final Sat sats;

  const Holding({
    required this.name,
    required this.symbol,
    required this.metadata,
    required this.sats,
  });

  // Adding the .empty() named constructor
  const Holding.empty()
      : name = '',
        symbol = '',
        metadata = const HoldingMetadata.empty(),
        sats = const Sat.empty();

  @override
  String toString() => '$runtimeType($props)';

  @override
  List<Object?> get props => <Object?>[
        name,
        symbol,
        metadata,
        sats,
      ];

  bool get isEmpty => sats.isEmpty;
}

class HoldingMetadata extends Equatable {
  final Divisibility divisibility;
  final bool reissuable;
  final Sat supply;

  const HoldingMetadata({
    required this.divisibility,
    required this.reissuable,
    required this.supply,
  });

  const HoldingMetadata.empty()
      : divisibility = const Divisibility.empty(),
        reissuable = false,
        supply = const Sat.empty();

  @override
  String toString() => '$runtimeType($props)';

  @override
  List<Object?> get props => <Object?>[
        divisibility,
        reissuable,
        supply,
      ];
}
