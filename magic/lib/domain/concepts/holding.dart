import 'package:equatable/equatable.dart';
import 'package:magic/domain/concepts/sats.dart';

class Holding extends Equatable {
  final String name;
  final String symbol;
  final String root;
  final HoldingMetadata metadata;
  final Sats sats;

  const Holding({
    required this.name,
    required this.symbol,
    required this.root,
    required this.metadata,
    required this.sats,
  });

  // Adding the .empty() named constructor
  const Holding.empty()
      : name = '',
        symbol = '',
        root = '',
        metadata = const HoldingMetadata.empty(),
        sats = const Sats.empty();

  @override
  String toString() => '$runtimeType($props)';

  @override
  List<Object?> get props => <Object?>[
        name,
        symbol,
        root,
        metadata,
        sats,
      ];

  bool get isEmpty => sats.isEmpty;
  bool get isRoot => symbol == root;
  Coin get coin => sats.toCoin;
}

class HoldingMetadata extends Equatable {
  final Divisibility divisibility;
  final bool reissuable;
  final Sats supply;

  const HoldingMetadata({
    required this.divisibility,
    required this.reissuable,
    required this.supply,
  });

  const HoldingMetadata.empty()
      : divisibility = const Divisibility.empty(),
        reissuable = false,
        supply = const Sats.empty();

  @override
  String toString() => '$runtimeType($props)';

  @override
  List<Object?> get props => <Object?>[
        divisibility,
        reissuable,
        supply,
      ];
}
