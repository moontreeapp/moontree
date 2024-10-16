import 'package:equatable/equatable.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/concepts/numbers/coin.dart';
import 'package:magic/domain/concepts/numbers/fiat.dart';
import 'package:magic/domain/concepts/numbers/sats.dart';
import 'package:magic/domain/server/protocol/comm_balance_view.dart';

class Holding extends Equatable {
  final String name;
  final String symbol;
  final HoldingMetadata metadata;
  final bool weHaveAdminOrMain;
  final Sats sats;
  final double? rate;
  final BalanceView? balanceView;
  final Blockchain blockchain;

  const Holding({
    required this.name,
    required this.symbol,
    required this.metadata,
    required this.sats,
    required this.blockchain,
    this.weHaveAdminOrMain = false,
    this.rate,
    this.balanceView,
  });

  // Adding the .empty() named constructor
  const Holding.empty()
      : name = '',
        symbol = '',
        metadata = const HoldingMetadata.empty(),
        sats = const Sats.empty(),
        weHaveAdminOrMain = false,
        rate = null,
        balanceView = null,
        blockchain = Blockchain.none;

  factory Holding.fromBalanceView({
    required BalanceView balanceView,
    required Blockchain blockchain,
    double? rate,
  }) =>
      Holding(
          name: balanceView.symbol,
          symbol: balanceView.symbol,
          metadata: const HoldingMetadata.empty(),
          sats: Sats(balanceView.satsConfirmed + balanceView.satsUnconfirmed),
          weHaveAdminOrMain: false,
          rate: rate,
          balanceView: balanceView,
          blockchain: blockchain);

  Holding copyWith({
    String? name,
    String? symbol,
    String? root,
    HoldingMetadata? metadata,
    Sats? sats,
    bool? weHaveAdminOrMain,
    double? rate,
    BalanceView? balanceView,
    Blockchain? blockchain,
  }) =>
      Holding(
          name: name ?? balanceView?.symbol ?? this.name,
          symbol: symbol ?? balanceView?.symbol ?? this.symbol,
          metadata: metadata ?? const HoldingMetadata.empty(),
          sats: sats ??
              (balanceView != null
                  ? Sats(
                      balanceView.satsConfirmed + balanceView.satsUnconfirmed)
                  : this.sats),
          weHaveAdminOrMain: weHaveAdminOrMain ?? this.weHaveAdminOrMain,
          rate: rate ?? this.rate,
          balanceView: balanceView ?? this.balanceView,
          blockchain: blockchain ?? this.blockchain);

  @override
  String toString() => '$runtimeType($props)';

  @override
  List<Object?> get props => <Object?>[
        name,
        symbol,
        metadata,
        sats,
        weHaveAdminOrMain,
        rate,
        balanceView,
        blockchain,
      ];

  bool get isEmpty => sats.isEmpty;
  bool get isCurrency => symbol == blockchain.symbol;
  bool get isEvrmore => isCurrency && symbol == 'EVR';
  bool get isRavencoin => isCurrency && symbol == 'RVN';
  bool get isOnEvrmore => blockchain.symbol == 'EVR';
  bool get isOnRavencoin => blockchain.symbol == 'RVN';

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
  String get assetPathChildNFT => assetPathChild.split('#').last;
  bool get isNft =>
      (isOnEvrmore || isOnRavencoin) && assetPathChild.contains('#');
  bool get isAdmin => symbol.endsWith('!') || name.endsWith('!');
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
