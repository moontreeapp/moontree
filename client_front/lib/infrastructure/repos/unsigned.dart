import 'package:client_back/records/records.dart';
import 'package:client_back/server/src/protocol/protocol.dart'
    show UnsignedTransactionResult;
import 'package:client_front/infrastructure/calls/unsigned.dart';
import 'package:client_front/infrastructure/repos/repository.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:wallet_utils/wallet_utils.dart';

class UnsignedTransactionRepo extends Repository<UnsignedTransactionResult> {
  late Wallet wallet;
  late String? symbol;
  late Security? security;
  late FeeRate? feeRate;
  final int sats;
  final String address;
  late Chain chain;
  late Net net;
  UnsignedTransactionRepo({
    Wallet? wallet,
    this.symbol,
    this.security,
    this.feeRate,
    required this.sats,
    required this.address,
    Chain? chain,
    Net? net,
  }) : super(UnsignedTransactionResult(
          error: 'fallback value',
          rawHex: '',
          vinPrivateKeySource: [],
          vinLockingScriptType: [],
        )) {
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
