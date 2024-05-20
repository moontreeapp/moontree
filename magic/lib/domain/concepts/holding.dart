import 'package:equatable/equatable.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/concepts/numbers/coin.dart';
import 'package:magic/domain/concepts/numbers/fiat.dart';
import 'package:magic/domain/concepts/numbers/sats.dart';
import 'package:magic/domain/server/protocol/comm_balance_view.dart';

class Holding extends Equatable {
  final String name;
  final String symbol;
  final String root;
  final HoldingMetadata metadata;
  final Sats sats;
  final double? rate;
  final BalanceView? balanceView;
  final Blockchain? blockchain;

  const Holding({
    required this.name,
    required this.symbol,
    required this.root,
    required this.metadata,
    required this.sats,
    this.rate,
    this.balanceView,
    this.blockchain,
  });

  // Adding the .empty() named constructor
  const Holding.empty()
      : name = '',
        symbol = '',
        root = '',
        metadata = const HoldingMetadata.empty(),
        sats = const Sats.empty(),
        rate = null,
        balanceView = null,
        blockchain = null;

  factory Holding.fromBalanceView({
    required BalanceView balanceView,
    required Blockchain blockchain,
    double? rate,
  }) =>
      Holding(
          name: balanceView.symbol,
          symbol: balanceView.symbol,
          root: blockchain.symbol,
          //root: balanceView.chain ?? blockchain.name,
          metadata: const HoldingMetadata.empty(),
          sats: Sats(balanceView.satsConfirmed + balanceView.satsUnconfirmed),
          rate: rate,
          balanceView: balanceView,
          blockchain: blockchain);

  Holding copyWith({
    String? name,
    String? symbol,
    String? root,
    HoldingMetadata? metadata,
    Sats? sats,
    BalanceView? balanceView,
    Blockchain? blockchain,
    double? rate,
  }) =>
      Holding(
          name: name ?? balanceView?.symbol ?? this.name,
          symbol: symbol ?? balanceView?.symbol ?? this.symbol,
          root: root ?? blockchain?.symbol ?? this.root,
          //root: balanceView.chain ?? blockchain.name,
          metadata: metadata ?? const HoldingMetadata.empty(),
          sats: sats ??
              (balanceView != null
                  ? Sats(
                      balanceView.satsConfirmed + balanceView.satsUnconfirmed)
                  : this.sats),
          rate: rate ?? this.rate,
          balanceView: balanceView ?? this.balanceView,
          blockchain: blockchain ?? this.blockchain);

  @override
  String toString() => '$runtimeType($props)';

  @override
  List<Object?> get props => <Object?>[
        name,
        symbol,
        root,
        metadata,
        sats,
        balanceView,
        blockchain,
      ];

  bool get isEmpty => sats.isEmpty;
  bool get isRoot => symbol == root;
  Coin get coin => sats.toCoin();
  Fiat get fiat {
    if (rate != null) {
      return coin.toFiat(rate!);
    }
    return const Fiat.empty();
  }

  bool get assetPathIsAChild => name.contains('/');
  String get assetPathParents => assetPathIsAChild
      ? name.split('/').sublist(0, name.split('/').length - 1).join('/')
      : name;
  String get assetPathChild => name.split('/').last;
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
