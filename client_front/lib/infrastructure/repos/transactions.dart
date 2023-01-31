import 'package:client_back/records/records.dart';
import 'package:client_back/server/src/protocol/protocol.dart' as protocol;
import 'package:client_front/infrastructure/cache/transactions.dart';
import 'package:client_front/infrastructure/calls/transactions.dart';
import 'package:client_front/infrastructure/repos/repository.dart';
import 'package:client_front/infrastructure/services/lookup.dart';

class TransactionHistoryRepo extends Repository {
  late Wallet wallet;
  late String? symbol;
  late Security? security;
  final int? height;
  late Chain chain;
  late Net net;
  late List<protocol.TransactionView> results;
  TransactionHistoryRepo({
    Wallet? wallet,
    this.symbol,
    this.security,
    this.height,
    Chain? chain,
    Net? net,
  }) : super() {
    this.wallet = wallet ?? Current.wallet;
    this.chain = chain ?? security?.chain ?? Current.chain;
    this.net = net ?? security?.net ?? Current.net;
  }

  /// gets values from server; if that fails, from cache; saves results
  /// and any errors encountered to self. saves to cache automatically.
  @override
  Future<List<protocol.TransactionView>> get() async {
    final resultServer = await fromServer();
    if (resultServer.length == 1 && resultServer.first.error != null) {
      errors[RepoSource.server] = resultServer.first.error!;
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
  Future<List<protocol.TransactionView>> fromServer() async =>
      TransactionHistoryCall(
        wallet: wallet,
        chain: chain,
        net: net,
        symbol: symbol,
        security: security,
        height: height,
      )();

  /// server does not give null, local does because local null always indicates
  /// error (missing data), whereas empty might indicate empty data.
  @override
  List<protocol.TransactionView>? fromLocal() => null;

  @override
  Future<void> save() async => TransactionsCache.put(
        wallet: wallet,
        height: height,
        chain: chain,
        net: net,
        records: results,
      );
}
