import 'package:client_back/records/records.dart';
import 'package:client_back/server/src/protocol/protocol.dart' as protocol;
import 'package:client_front/infrastructure/calls/unsigned.dart';
import 'package:client_front/infrastructure/repos/repository.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:wallet_utils/wallet_utils.dart';

class UnsignedTransactionRepo extends Repository {
  late Wallet wallet;
  late String? symbol;
  late Security? security;
  late FeeRate? feeRate;
  final int sats;
  final String address;
  late Chain chain;
  late Net net;
  late protocol.UnsignedTransactionResult results;
  UnsignedTransactionRepo({
    Wallet? wallet,
    this.symbol,
    this.security,
    this.feeRate,
    required this.sats,
    required this.address,
    Chain? chain,
    Net? net,
  }) : super() {
    this.chain = chain ?? security?.chain ?? Current.chain;
    this.net = net ?? security?.net ?? Current.net;
    this.wallet = wallet ?? Current.wallet;
  }

  /// gets values from server; if that fails, from cache; saves results
  /// and any errors encountered to self. saves to cache automatically.
  @override
  Future<protocol.UnsignedTransactionResult> get() async {
    final resultServer = await fromServer();
    if (resultServer.error != null) {
      print('UnsignedTransactionRepo error: ${resultServer.error}');
      errors[RepoSource.server] = resultServer.error!;
      final resultCache = fromLocal();
      if (resultCache == null) {
        errors[RepoSource.local] = 'cache not implemented'; //'nothing cached'
      } else {
        results = resultCache;
      }
    } else {
      results = resultServer;
      save();
    }
    return resultServer;
  }

  @override
  Future<protocol.UnsignedTransactionResult> fromServer() async =>
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
  protocol.UnsignedTransactionResult? fromLocal() => null;

  @override
  Future<void> save() async => // todo: add results to correct cache.
      null;
}
