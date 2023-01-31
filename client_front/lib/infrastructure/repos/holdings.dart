import 'package:client_back/records/records.dart';
import 'package:client_back/server/src/protocol/protocol.dart' as protocol;
import 'package:client_front/infrastructure/calls/holdings.dart';
import 'package:client_front/infrastructure/cache/holdings.dart';
import 'package:client_front/infrastructure/repos/repository.dart';
import 'package:client_front/infrastructure/services/lookup.dart';

class HoldingsRepo extends Repository {
  late Wallet wallet;
  late Chain chain;
  late Net net;
  late List<protocol.BalanceView> results;
  HoldingsRepo({
    Wallet? wallet,
    Chain? chain,
    Net? net,
  }) : super() {
    this.chain = chain ?? Current.chain;
    this.net = net ?? Current.net;
    this.wallet = wallet ?? Current.wallet;
  }

  /// gets values from server; if that fails, from cache; saves results
  /// and any errors encountered to self. saves to cache automatically.
  @override
  Future<List<protocol.BalanceView>> get() async {
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
  Future<List<protocol.BalanceView>> fromServer() async =>
      HoldingBalancesCall(wallet: wallet, chain: chain, net: net)();

  /// server does not give null, local does because local null always indicates
  /// error (missing data), whereas empty might indicate empty data.
  @override
  List<protocol.BalanceView>? fromLocal() => null;

  @override
  Future<void> save() async => HoldingsCache.put(
        wallet: wallet,
        chain: chain,
        net: net,
        records: results,
      );
}
