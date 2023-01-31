import 'dart:convert';
import 'package:client_back/client_back.dart';
import 'package:client_back/server/serverv2_client.dart'
    show SerializableEntity;
import 'package:client_back/server/src/protocol/comm_balance_view.dart';
import 'package:client_back/server/src/protocol/protocol.dart' show Protocol;

class HoldingsCache extends Cache {
  /// accepts a list of BalanceView objects and saves them as balances in cache
  static Future<void> put({
    required Wallet wallet,
    required Chain chain,
    required Net net,
    required List<BalanceView> records,
  }) async {
    List<CachedServerObject> cached = [];
    for (final BalanceView record in records) {
      // not sure if we really need to save securities, maybe at all.
      Security? security =
          pros.securities.byKey.getOne(record.symbol, chain, net);
      if (security == null) {
        security = Security(symbol: record.symbol, chain: chain, net: net);
        await pros.securities
            .save(Security(symbol: record.symbol, chain: chain, net: net));
      }
      cached.add(CachedServerObject(
        type: 'BalanceView',
        json: json.encode(record.toJson()),
        walletId: wallet.id,
        chain: chain,
        net: net,
      ));
    }
    await pros.cache.saveAll(cached);
  }

  /// accepts a list of TransactionView objects and saves them as balances in cache
  static Future<List<BalanceView>?> get({
    required Wallet wallet,
    required Chain chain,
    required Net net,
    required int? height,
  }) async =>
      [
        for (final x in pros.cache.byHolding
            .getAll('BalanceView', wallet.id, chain, net))
          Protocol().deserialize(json.decode(x.json), BalanceView)
      ];
  //pros.transactions.get by something... ; // translate to BalanceView?
}

class Cache {
  /// accepts a list of BalanceView objects and saves them as balances in cache
  static Future<void> save({
    String? walletId,
    String? symbol,
    Chain? chain,
    Net? net,
    required String type,
    required List<SerializableEntity> records,
  }) async =>
      await pros.cache.saveAll([
        for (final SerializableEntity record in records)
          CachedServerObject(
            type: type,
            json: json.encode(record.toJson()),
            serverId: (record as dynamic).id,
            walletId: walletId,
            chain: chain,
            net: net,
            symbol: symbol,
          )
      ]);
}
