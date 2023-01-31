/// this is not fully fleshed out yet because at present we don't have a need to
/// cache transactions. we'll get more into the details of how to save them in
/// cache later. it's a little complex because we have to combine this data with
/// the transaction details data. for now we did the minimal effort.

import 'package:client_back/client_back.dart';
import 'package:client_back/server/src/protocol/comm_transaction_view.dart';
import 'package:moontree_utils/extensions/bytedata.dart';

class TransactionsCache {
  /// accepts a list of TransactionView objects and saves them as balances in cache
  static Future<void> put({
    required Wallet wallet,
    required Chain chain,
    required Net net,
    required int? height,
    required List<TransactionView> records,
  }) async =>
      // should we save it in the transactionView, specific format, or in the more
      // generalized Transaction-Vout format in preparation for the future?
      // probably we shouldn't prematurely optimize, and should instead make a
      // TransactionViewRecord for hive boxes. then make it more general later if
      // need be. but for now just save a tx object.
      await pros.transactions.saveAll([
        for (final TransactionView record in records)
          Transaction(
            id: record.hash.toHex(),
            confirmed: record.height > 0,
            time: record.datetime.millisecondsSinceEpoch ~/ 1000,
            height: record.height,
          )
      ]);

  /// accepts a list of TransactionView objects and saves them as balances in cache
  static Future<List<TransactionView>?> get({
    required Wallet wallet,
    required Chain chain,
    required Net net,
    required int? height,
  }) async =>
      null;
  //pros.transactions.get by something... ;
}
