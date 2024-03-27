import 'package:equatable/equatable.dart';
import 'package:moontree/domain/concepts/sats.dart';

class Holding extends Equatable {
  final String name;
  final String symbol;
  final HoldingMetadata metadata;
  final Sats sats;

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
        sats = const Sats.empty();

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
