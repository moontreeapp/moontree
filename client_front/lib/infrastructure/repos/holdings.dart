import 'package:client_back/records/records.dart';
import 'package:client_back/proclaim/proclaim.dart';
import 'package:client_back/server/src/protocol/protocol.dart' show BalanceView;
import 'package:client_front/infrastructure/calls/holdings.dart';
import 'package:client_front/infrastructure/cache/holdings.dart';
import 'package:client_front/infrastructure/repos/repository.dart';
import 'package:client_front/infrastructure/services/lookup.dart';

class HoldingsRepo extends Repository<Iterable<BalanceView>> {
  late Wallet wallet;
  late Chain chain;
  late Net net;
  HoldingsRepo({
    Wallet? wallet,
    Chain? chain,
    Net? net,
  }) : super(generateFallback) {
    this.chain = chain ?? Current.chain;
    this.net = net ?? Current.net;
    this.wallet = wallet ?? Current.wallet;
  }
  static Iterable<BalanceView> generateFallback([String? error]) =>
      <BalanceView>[];

  @override
  bool detectServerError(dynamic resultServer) =>
      resultServer.length == 1 && resultServer.first.error != null;

  @override
  bool detectLocalError(dynamic resultLocal) => resultLocal.length == 0;

  @override
  String extractError(dynamic resultServer) => resultServer.first.error!;

  @override
  Future<Iterable<BalanceView>> fromServer() async =>
      //[BalanceView(error: 'fake error', sats: 0, symbol: '')]; // testing
      HoldingBalancesCall(wallet: wallet, chain: chain, net: net)();

  /// server does not give null, local does because local null always indicates
  /// error (missing data), whereas empty might indicate empty data.
  @override
  Iterable<BalanceView>? fromLocal() =>
      HoldingsCache.get(wallet: wallet, chain: chain, net: net);

  @override
  Future<void> save() async {
    HoldingsCache.put(
      wallet: wallet,
      chain: chain,
      net: net,
      records: results,
    );
    // here we save securities since we have so much logic that uses them.
    pros.securities.saveAll(
        results.map((e) => Security(symbol: e.symbol, chain: chain, net: net)));
  }
}
