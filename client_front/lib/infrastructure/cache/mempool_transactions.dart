import 'package:client_back/client_back.dart';
import 'package:client_back/server/src/protocol/protocol.dart'
    show TransactionView;
import 'package:client_front/infrastructure/cache/cache.dart';

class MempoolTransactionsCache {
  /// accepts a list of TransactionView objects and saves them as balances in cache
  static Future<void> put({
    required Wallet wallet,
    required Chain chain,
    required Net net,
    required Iterable<TransactionView> records,
  }) async =>
      Cache.save(
        records,
        'TransactionView',
        walletId: wallet.id,
        chain: chain,
        net: net,
        saveTxHashes: true,
        saveHeights: true,
      );

  /// gets list of TransactionView objects from cache
  static Iterable<TransactionView>? get({
    required Wallet wallet,
    required Chain chain,
    required Net net,
    required String symbol,
    int? height,
  }) =>
      pros.cache.byTransactions
          .getAll(symbol, wallet.id, chain, net)
          .map((e) => Cache.read<TransactionView>(e))
          .where((e) => e.height <= 0);
}
