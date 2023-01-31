import 'package:client_back/client_back.dart';
import 'package:client_back/server/src/protocol/protocol.dart'
    show TransactionView;
import 'package:client_front/infrastructure/cache/cache.dart';

class TransactionsCache {
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
      /*
      * notice height is ignored here. that is because filtering on pros is
      * always directly equal to, not within a range, which is ok. we can grab
      * them all and paginate later if we need to. but I don't think we'll
      * need to. maybe. until then we just return all the transactions for
      * this wallet-chain-net-symbol combination. Except there's an edge case
      * we have to handle. if the user has already seen all the transactions
      * we shouldn't return any. so we do need to check the height in that case.
      //height == null
      //    ? pros.cache.byTransactions
      //        .getAll(symbol, wallet.id, chain, net)
      //        .map((e) => Cache.read<TransactionView>(e))
      //    : pros.cache.byTransactionsByHeight
      //        .getAll(height, symbol, wallet.id, chain, net)
      //        .map((e) => Cache.read<TransactionView>(e));
      */
      pros.cache.byTransactions
          .getAll(symbol, wallet.id, chain, net)
          .map((e) => Cache.read<TransactionView>(e))
          .where((e) => e.height > (height ?? 0));
}
