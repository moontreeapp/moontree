import 'package:client_back/records/records.dart';
import 'package:client_back/server/src/protocol/protocol.dart'
    show UnsignedTransactionResult;
import 'package:client_front/infrastructure/calls/unsigned.dart';
import 'package:client_front/infrastructure/repos/repository.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:wallet_utils/wallet_utils.dart';

class UnsignedTransactionRepo extends Repository<UnsignedTransactionResult> {
  late Wallet wallet;
  late Chain chain;
  late Net net;
  final String? symbol;
  final Security? security;
  final FeeRate? feeRate;
  final String? changeAddress; // if not supplied, server defaults to index 0
  final String? memo;
  final int sats;
  final String address;
  UnsignedTransactionRepo({
    this.symbol,
    this.security,
    this.feeRate,
    this.changeAddress,
    this.memo,
    required this.sats,
    required this.address,
    Wallet? wallet,
    Chain? chain,
    Net? net,
  }) : super(UnsignedTransactionResult(
            error: 'failure to generate Unsigned Transaction',
            rawHex: '',
            vinPrivateKeySource: [],
            vinLockingScriptType: [],
            changeSource: [],
            vinScriptOverride: [],
            vinAssets: [],
            vinAmounts: [],
            targetFee: 0)) {
    this.chain = chain ?? security?.chain ?? Current.chain;
    this.net = net ?? security?.net ?? Current.net;
    this.wallet = wallet ?? Current.wallet;
  }

  @override
  Future<UnsignedTransactionResult> fromServer() async =>
      UnsignedTransactionCall(
        wallet: wallet,
        chain: chain,
        net: net,
        symbol: symbol,
        security: security,
        feeRate: feeRate,
        memo: memo,
        changeAddress: changeAddress,
        sats: sats,
        address: address,
      )();

  /// server does not give null, local does because local null always indicates
  /// error (missing data), whereas empty might indicate empty data.
  @override
  UnsignedTransactionResult? fromLocal() => null;

  /// don't save or retrieve unsigned tx, make them anew everytime
  @override
  Future<void> save() async => null;
}
