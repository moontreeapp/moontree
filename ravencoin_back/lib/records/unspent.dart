import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_electrum/methods/scripthash/unspent.dart';

import '_type_id.dart';

part 'unspent.g.dart';

@HiveType(typeId: TypeId.Unspent)
class Unspent with EquatableMixin, ToStringMixin {
  @HiveField(0)
  String walletId;

  @HiveField(1)
  String addressId;

  @HiveField(2)
  String transactionId;

  @HiveField(3)
  int position;

  @HiveField(4)
  int height;

  @HiveField(5)
  int value;

  @HiveField(6)
  String symbol;

  @HiveField(7, defaultValue: Chain.ravencoin)
  final Chain chain;

  @HiveField(8, defaultValue: Net.main)
  final Net net;

  Unspent({
    required this.walletId,
    required this.addressId,
    required this.transactionId,
    required this.position,
    required this.height,
    required this.value,
    required this.symbol,
    required this.chain,
    required this.net,
  });

  factory Unspent.fromScripthashUnspent(
    String walletId,
    ScripthashUnspent scripthashUnspent,
    Chain chain,
    Net net,
  ) {
    return Unspent(
      walletId: walletId,
      addressId: scripthashUnspent.scripthash,
      transactionId: scripthashUnspent.txHash,
      position: scripthashUnspent.txPos,
      height: scripthashUnspent.height,
      value: scripthashUnspent.value,
      symbol: scripthashUnspent.symbol ??
          (chain == Chain.ravencoin ? 'RVN' : 'EVR'),
      chain: chain,
      net: net,
    );
  }

  factory Unspent.from(
    Unspent unspent, {
    String? walletId,
    String? transactionId,
    String? addressId,
    int? position,
    int? height,
    int? value,
    String? symbol,
    Chain? chain,
    Net? net,
  }) {
    return Unspent(
      walletId: walletId ?? unspent.walletId,
      addressId: addressId ?? unspent.addressId,
      transactionId: transactionId ?? unspent.transactionId,
      position: position ?? unspent.position,
      height: height ?? unspent.height,
      value: value ?? unspent.value,
      symbol: symbol ?? (chain != null ? chainSymbol(chain) : unspent.symbol),
      chain: chain ?? unspent.chain,
      net: net ?? unspent.net,
    );
  }

  @override
  List<Object?> get props => [
        addressId,
        transactionId,
        position,
        height,
        value,
        symbol,
        chain,
        net,
      ];

  @override
  bool? get stringify => true;

  @override
  List<String> get propNames => [
        'addressId',
        'transactionId',
        'position',
        'height',
        'value',
        'symbol',
        'chain',
        'net',
      ];

  String get scripthash => addressId;
  String get txHash => transactionId;
  String get id => key(transactionId, position, chain, net);
  int get confirmed => isConfirmed ? value : 0;
  int get unconfirmed => isUnconfirmed ? value : 0;

  bool get isConfirmed => height > 0;
  bool get isUnconfirmed => height <= 0;

  String get walletSymbolId => getWalletSymbolId(walletId, symbol);
  String get walletConfirmationId =>
      getWalletConfirmationId(walletId, isConfirmed);
  String get walletSymbolConfirmationId =>
      getWalletSymbolConfirmationId(walletId, symbol, isConfirmed);

  static String getWalletSymbolId(String walletId, String symbol) =>
      '$walletId:$symbol';
  static String getWalletChainId(String walletId, Chain chain, Net net) =>
      '$walletId:${chainNetKey(chain, net)}';
  static String getWalletChainSymbolId(
          String walletId, Chain chain, Net net, String symbol) =>
      '$walletId:${chainNetKey(chain, net)}:$symbol';
  static String getSymbolChainId(String symbol, Chain chain, Net net) =>
      '${chainNetKey(chain, net)}:$symbol';
  static String getWalletConfirmationId(String walletId, bool isConfirmed) =>
      '$walletId:${isConfirmed.toString()}';
  static String getWalletSymbolConfirmationId(
          String walletId, String symbol, bool isConfirmed) =>
      '$walletId:$symbol:${isConfirmed.toString()}';
  static String getWalletChainConfirmationId(
          String walletId, Chain chain, Net net, bool isConfirmed) =>
      '$walletId:${chainNetKey(chain, net)}:${isConfirmed.toString()}';
  static String getWalletChainSymbolConfirmationId(String walletId, Chain chain,
          Net net, String symbol, bool isConfirmed) =>
      '$walletId:${chainNetKey(chain, net)}:$symbol:${isConfirmed.toString()}';

  static String key(String transactionId, int position, Chain chain, Net net) =>
      '$transactionId:$position:${chainNetKey(chain, net)}';

  String get voutId => Vout.key(transactionId, position);

  Security get security => symbol == 'RVN'
      ? pros.securities.RVN
      : Security(
          symbol: symbol,
          securityType: SecurityType.asset,
          chain: chain,
          net: net);
}
