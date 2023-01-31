import 'package:client_back/client_back.dart';
import 'package:client_back/server/src/protocol/asset_metadata_class.dart';
import 'package:moontree_utils/extensions/bytedata.dart';

class AssetCache {
  /// accepts a list of AssetMetadata objects and saves them as balances in cache
  static Future<void> put({
    required String symbol,
    required Chain chain,
    required Net net,
    required List<AssetMetadata> records,
  }) async =>
      await pros.assets.saveAll([
        for (final AssetMetadata record in records)
          Asset(
            symbol: symbol,
            chain: chain,
            net: net,
            // if we need the the txs history of this asset (created and reissues)
            // we'll grab it on demand separately.
            //transactionId: '',
            //position: record.voutId, // not the position, the id in the database...
            totalSupply: record.totalSupply,
            divisibility: record.divisibility,
            reissuable: record.reissuable,
            frozen: record.frozen,
            metadata: record.associatedData?.toBs58() ?? '',
          )
      ]);

  /// accepts a list of TransactionView objects and saves them as balances in cache
  static Future<List<AssetMetadata>?> get({
    required Wallet wallet,
    required Chain chain,
    required Net net,
    required int? height,
  }) async =>
      null;
  //pros.transactions.get by something... ; // translate to assetMetadata?
}
