import 'package:client_back/records/records.dart';
import 'package:client_back/server/src/protocol/protocol.dart'
    show UnsignedTransactionResult;
import 'package:client_back/utilities/structures.dart';
import 'package:client_front/infrastructure/calls/unsigned_create.dart';
import 'package:client_front/infrastructure/repos/repository.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:wallet_utils/wallet_utils.dart';

class UnsignedCreateRepo extends Repository<UnsignedTransactionResult> {
  late Wallet wallet;
  late Chain chain;
  late Net net;
  final FeeRate? feeRate;
  final String? changeAddress; // if not supplied, server defaults to index 0
  final String? memo;
  final SymbolType symbolType;
  final String symbol;
  final bool reissuable;
  final String? parentSymbol;
  final int? divisibility;
  final int? quantity;
  final String? assetMemo;
  final String? verifierString;

  UnsignedCreateRepo({
    required this.symbolType,
    required this.symbol,
    required this.reissuable,
    this.parentSymbol,
    this.divisibility,
    this.quantity,
    this.assetMemo,
    this.verifierString,
    this.feeRate,
    this.changeAddress,
    this.memo,
    Wallet? wallet,
    Chain? chain,
    Net? net,
  }) : super(generateFallback) {
    this.chain = chain ?? Current.chain;
    this.net = net ?? Current.net;
    this.wallet = wallet ?? Current.wallet;
  }

  static UnsignedTransactionResult generateFallback(String error) =>
      UnsignedTransactionResult(
          error: error,
          rawHex: '',
          vinPrivateKeySource: [],
          vinLockingScriptType: [],
          changeSource: [],
          vinScriptOverride: [],
          vinAssets: [],
          vinAmounts: [],
          targetFee: 0);

  @override
  bool detectServerError(dynamic resultServer) => resultServer.error != null;

  @override
  bool detectLocalError(dynamic resultLocal) => resultLocal.error != null;

  @override
  String extractError(dynamic resultServer) => resultServer.error!;

  @override
  Future<UnsignedTransactionResult> fromServer() async => UnsignedCreateCall(
        wallet: wallet,
        chain: chain,
        net: net,
        feeRate: feeRate,
        changeAddress: changeAddress,
        symbolType: symbolType,
        symbol: symbol,
        parentSymbol: parentSymbol,
        reissuable: reissuable,
        divisibility: divisibility,
        quantity: quantity,
        assetMemo: assetMemo,
        memo: memo,
        verifierString: verifierString,
      )();

  /// server does not give null, local does because local null always indicates
  /// error (missing data), whereas empty might indicate empty data.
  @override
  UnsignedTransactionResult? fromLocal() => null;

  /// don't save or retrieve unsigned tx, make them anew everytime
  @override
  Future<void> save() async => null;
}
