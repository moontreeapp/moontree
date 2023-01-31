import 'dart:typed_data';
import 'package:moontree_utils/extensions/bytedata.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/server/src/protocol/protocol.dart'
    show TransactionDetailsView;
import 'package:client_front/infrastructure/cache/cache.dart';

class TransactionCache {
  /// accepts a list of TransactionView objects and saves them as balances in cache
  static Future<void> put({
    required Wallet wallet,
    required Chain chain,
    required Net net,
    required ByteData txHash,
    required TransactionDetailsView record,
  }) async =>
      Cache.save(
        [record],
        'TransactionDetailsView',
        walletId: wallet.id,
        chain: chain,
        net: net,
        txHash: txHash.toHex(),
      );

  /// gets list of TransactionView objects from cache
  static TransactionDetailsView? get({
    required Wallet wallet,
    required Chain chain,
    required Net net,
    required ByteData txHash,
  }) {
    final x = pros.cache.byTransactionDetail
        .getOne(txHash.toHex(), wallet.id, chain, net);
    if (x == null) return null;
    return Cache.read<TransactionDetailsView>(x);
  }
}
