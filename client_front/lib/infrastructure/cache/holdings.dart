import 'package:client_back/client_back.dart';
import 'package:client_back/server/src/protocol/comm_balance_view.dart';

class HoldingsCache {
  /// accepts a list of BalanceView objects and saves them as balances in cache
  static Future<void> put({
    required Wallet wallet,
    required Chain chain,
    required Net net,
    required List<BalanceView> records,
  }) async {
    List<Balance> balances = [];
    for (final BalanceView record in records) {
      Security? security =
          pros.securities.byKey.getOne(record.symbol, chain, net);
      if (security == null) {
        security = Security(symbol: record.symbol, chain: chain, net: net);
        await pros.securities
            .save(Security(symbol: record.symbol, chain: chain, net: net));
      }
      balances.add(Balance(
        walletId: wallet.id,
        security: security,
        confirmed: record.sats,
        unconfirmed: 0,
      ));
    }
    await pros.balances.saveAll(balances);
  }

  /// accepts a list of TransactionView objects and saves them as balances in cache
  static Future<List<BalanceView>?> get({
    required Wallet wallet,
    required Chain chain,
    required Net net,
    required int? height,
  }) async =>
      null;
  //pros.transactions.get by something... ; // translate to BalanceView?
}
