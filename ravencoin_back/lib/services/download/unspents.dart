import 'dart:async';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_electrum/ravencoin_electrum.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

enum ValueType { confirmed, unconfirmed }

/// we use the electrum server directly for determining our UTXO set
class UnspentService {
  void _maybeTriggerBackup(Iterable<ScripthashUnspent> unspents) {
    if (unspents.isNotEmpty && pros.unspents.isEmpty) {
      streams.app.triggers.add(ThresholdTrigger.backup);
    }
  }

  void _maybeSubscribeToAsset({
    required String symbol,
    bool subscribe = false,
  }) {
    if (pros.unspents.bySymbol.getAll(symbol).isEmpty) {
      if (subscribe && symbol != 'RVN') {
        // Subscribe to a dummy asset of this type
        // This method checks if we're already subscribed and
        // handles downloads if we are not
        services.client.subscribe.toAsset(Asset(
            symbol: symbol,
            satsInCirculation: 0,
            divisibility: 0,
            reissuable: false,
            metadata: '',
            transactionId: '',
            position: 0));
      }
    }
  }

  /// pull unspents and save them to proclaim
  Future<void> pull({
    required Wallet wallet,
    required Set<String> scripthashes,
    bool getTransactions = true,
  }) async {
    var utxos = <Unspent>{};

    /// update RVN call
    var rvnUtxos = (await services.client.api.getUnspents(scripthashes))
        .expand((i) => i)
        .toList();
    for (var utxo in rvnUtxos) {
      utxos.add(Unspent.fromScripthashUnspent(wallet.id, utxo));
    }

    /// update assets call
    var assetUtxos = (await services.client.api.getAssetUnspents(scripthashes))
        .expand((i) => i)
        .toList();
    for (final utxo in assetUtxos) {
      // should never be null but can't hurt to be safe. this filters out utxos
      // that are for assets, but have a null symbol which we would interpret as
      // rvn... but we already know none of these are rvn, so don't save it.
      if (utxo.symbol != null) {
        utxos.add(Unspent.fromScripthashUnspent(wallet.id, utxo));
        _maybeSubscribeToAsset(symbol: utxo.symbol!, subscribe: true);
      } else {
        // raise to notify in here?
      }
    }

    _maybeTriggerBackup(rvnUtxos);
    _maybeTriggerBackup(assetUtxos);

    // only save if there's something new, in that case erase all, save all.
    var existing = pros.unspents.byScripthashes(scripthashes).toSet();
    await pros.unspents.removeAll(existing.difference(utxos));
    await pros.unspents.saveAll(utxos.difference(existing));
    if (getTransactions && utxos.isNotEmpty) {
      /// we don't want to queue these because that makes it hard to know when
      /// vouts are downloaded for these unspents. If we await the download
      /// here, instead, we can easily make the send button available when vouts
      /// for all unspents are downloaded
      //await services.download.queue.update(
      //  txids: utxos.map((e) => e.transactionId).toSet(),
      //);
      await services.download.history
          .getAndSaveTransactions(utxos.map((e) => e.transactionId).toSet());
    }
  }
}
