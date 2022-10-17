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

  Unspent({
    required this.walletId,
    required this.addressId,
    required this.transactionId,
    required this.position,
    required this.height,
    required this.value,
    this.symbol = 'RVN',
  });

  factory Unspent.fromScripthashUnspent(
    String walletId,
    ScripthashUnspent scripthashUnspent,
  ) {
    return Unspent(
      walletId: walletId,
      addressId: scripthashUnspent.scripthash,
      transactionId: scripthashUnspent.txHash,
      position: scripthashUnspent.txPos,
      height: scripthashUnspent.height,
      value: scripthashUnspent.value,
      symbol: scripthashUnspent.symbol ?? 'RVN',
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
      ];

  String get scripthash => addressId;
  String get txHash => transactionId;
  String get id => getUnspentId(transactionId, position);
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
      walletId + ':' + symbol;
  static String getWalletConfirmationId(String walletId, bool isConfirmed) =>
      walletId + ':' + isConfirmed.toString();
  static String getWalletSymbolConfirmationId(
          String walletId, String symbol, bool isConfirmed) =>
      walletId + ':' + symbol + ':' + isConfirmed.toString();

  static String getUnspentId(String transactionId, int position) =>
      '$transactionId:$position';

  Security get security => symbol == 'RVN'
      ? pros.securities.RVN
      : Security(symbol: symbol, securityType: SecurityType.asset);
}
