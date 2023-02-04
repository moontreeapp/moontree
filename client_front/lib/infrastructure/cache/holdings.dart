import 'package:client_back/client_back.dart';
import 'package:client_back/server/src/protocol/protocol.dart' show BalanceView;
import 'package:client_front/infrastructure/cache/cache.dart';

class HoldingsCache {
  /// accepts a list of BalanceView objects and saves them as balances in cache
  static Future<void> put({
    required Wallet wallet,
    required Chain chain,
    required Net net,
    required Iterable<BalanceView> records,
  }) async {
    await Cache.save(
      records,
      'BalanceView',
      walletId: wallet.id,
      chain: chain,
      net: net,
      saveSymbols: true,
    );
    await pros.balances.saveAll([
      for (final record in records)
        Balance(
            walletId: wallet.id,
            confirmed: record.satsConfirmed,
            unconfirmed: record.satsUnconfirmed,
            security: Security(chain: chain, net: net, symbol: record.symbol))
    ]);
  }

  /// gets list of BalanceView objects from cache
  static Iterable<BalanceView>? get({
    required Wallet wallet,
    required Chain chain,
    required Net net,
  }) =>
      pros.cache.byHolding
          .getAll(wallet.id, chain, net)
          .map((e) => Cache.read<BalanceView>(e));
}
