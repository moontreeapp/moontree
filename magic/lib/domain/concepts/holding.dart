import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/concepts/numbers/coin.dart';
import 'package:magic/domain/concepts/numbers/fiat.dart';
import 'package:magic/domain/concepts/numbers/sats.dart';
import 'package:magic/domain/server/protocol/comm_balance_view.dart';

class Asset extends Equatable {
  final String name;
  final String symbol;
  final Blockchain blockchain;

  const Asset({
    required this.name,
    required this.symbol,
    required this.blockchain,
  });

  const Asset.empty()
      : name = '',
        symbol = '',
        blockchain = Blockchain.none;

  factory Asset.fromHolding({
    required Holding holding,
  }) =>
      Asset(
          name: holding.name,
          symbol: holding.symbol,
          blockchain: holding.blockchain);

  @override
  String toString() => '$runtimeType($props)';

  @override
  List<Object?> get props => <Object?>[
        name,
        symbol,
        blockchain,
      ];

  String get uniqueId => '$name-$blockchain';
}

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

  factory Holding.fromMap({required Map<String, dynamic> map}) => Holding(
      name: map['name'] as String,
      symbol: map['symbol'] as String,
      metadata: HoldingMetadata(
        divisibility: Divisibility(map['metadata']['divisibility'] as int),
        reissuable: map['metadata']['reissuable'] as bool,
        supply: Sats(map['metadata']['supply'] as int),
      ),
      sats: Sats(map['sats']['value'] as int,
          isEmpty: map['sats']['isEmpty'] as bool),
      weHaveAdminOrMain: map['weHaveAdminOrMain'] as bool,
      rate: map['rate'] as double?,
      blockchain: Blockchain.from(name: map['blockchain']));

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

  String get uniqueId => '$name-$blockchain';

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'symbol': symbol,
      'metadata': {
        'divisibility': metadata.divisibility.value,
        'reissuable': metadata.reissuable,
        'supply': metadata.supply
      },
      'sats': {
        'value': sats.value,
        'isEmpty': sats.isEmpty,
      },
      'weHaveAdminOrMain': weHaveAdminOrMain,
      'rate': rate,
      'blockchain': blockchain,
    };
  }

  bool get isEmpty => sats.isEmpty;
  bool get isCurrency => symbol == blockchain.symbol;
  bool get isEvrmore => isCurrency && symbol == 'EVR';
  bool get isRavencoin => isCurrency && symbol == 'RVN';
  bool get isOnEvrmore => blockchain.symbol == 'EVR';
  bool get isOnRavencoin => blockchain.symbol == 'RVN';

  Asset get asset => Asset.fromHolding(holding: this);
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
