import 'dart:async';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_electrum/ravencoin_electrum.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:json_rpc_2/json_rpc_2.dart' as rpc;

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
    required Chain chain,
    required Net net,
    bool subscribe = false,
  }) {
    if (pros.unspents.bySymbol.getAll(symbol).isEmpty) {
      if (subscribe &&
          !(symbol == 'RVN' && chain == Chain.ravencoin) &&
          !(symbol == 'EVR' && chain == Chain.evrmore)) {
        // Subscribe to a dummy asset of this type
        // This method checks if we're already subscribed and
        // handles downloads if we are not
        services.client.subscribe.toAsset(Asset(
            chain: chain,
            net: net,
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
    required Chain chain,
    required Net net,
    bool getTransactions = true,
  }) async {
    var utxos = <Unspent>{};
    if (scripthashes.contains(
        'e5886c1ed52b9b59a10cb17e7430f26d293b213777b0dc30f999bee9a9cde566')) {
      print('here');
    }

    /// update RVN call
    var currencyUtxos = (await services.client.api.getUnspents(scripthashes))
        .expand((i) => i)
        .toList();
    for (var utxo in currencyUtxos) {
      utxos.add(Unspent.fromScripthashUnspent(wallet.id, utxo, chain, net));
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
        utxos.add(Unspent.fromScripthashUnspent(wallet.id, utxo, chain, net));
        _maybeSubscribeToAsset(
            symbol: utxo.symbol!, subscribe: true, chain: chain, net: net);
      } else {
        // raise to notify in here?
      }
    }

    _maybeTriggerBackup(currencyUtxos);
    _maybeTriggerBackup(assetUtxos);

    // only save if there's something new, in that case erase all, save all.
    var existing = pros.unspents.byScripthashes(scripthashes).toSet();
    await pros.unspents.removeAll(existing.difference(utxos));
    await pros.unspents.saveAll(utxos.difference(existing));

    /// edge case: Evrmore genesis block is too large to download, so if we
    /// detect the utxo with a (height of 0 and on Chain.evrmore) or a txid of
    /// c191c775b10d2af1fcccb4121095b2a018f1bee84fa5efb568fcddd383969262
    /// then we have a "claim" situation. We want to halt downloading
    /// transactions and instead make a Vout from the Unspent. Since it's not an
    /// asset we don't need the lockingScript so we don't need to get the Vout
    /// from the transaction, which is lucky for us because it's too big to
    /// handle in the current implementation. So. I think the best way to do
    /// this is to make the Vout from the unspent here, pass it to a stream
    /// then use that stream to avoid downloading any transactions later on, and
    /// to make and sign the claim transaction.
    if (utxos.map((e) => e.txHash).contains(
        'c191c775b10d2af1fcccb4121095b2a018f1bee84fa5efb568fcddd383969262')) {
      // make vout
      // pass to stream
      // also pass null to stream when clearing database
      // avoid downloading transactions if stream is not null
      // use the contents of the stream to make the sweep transaction in
      //   special claim sweep tx maker function.
    } else if (getTransactions && utxos.isNotEmpty) {
      /// we don't want to queue these because that makes it hard to know when
      /// vouts are downloaded for these unspents. If we await the download
      /// here, instead, we can easily make the send button available when vouts
      /// for all unspents are downloaded
      //await services.download.queue.update(
      //  txids: utxos.map((e) => e.transactionId).toSet(),
      //);

      /// noticed that during a reorg we can get error about tx not found
      ///   Exception has occurred.
      ///     RpcException (JSON-RPC error 2: daemon error: DaemonError({
      ///       'code': -5,
      ///       'message': 'No such mempool or blockchain transaction. Use gettransaction for wallet transactions.'}))
      //await services.download.history
      //  .getAndSaveTransactions(utxos.map((e) => e.transactionId).toSet());
      /// so try it all first, because that's much more efficient, if you fail,
      /// try one at a time:
      final txids = services.download.history
          .filterOutPreviouslyDownloaded(utxos.map((e) => e.transactionId))
          .toSet();
      if (txids.isNotEmpty) {
        await services.download.history.getAndSaveTransactions(txids);
        try {
          await services.download.history.getAndSaveTransactions(txids);
          //} catch rpc.RpcException(e) {//(/JSON-RPC error -32600 (invalid request): response too large (over 10,000,000 bytes)) {
        } catch (e) {
          print(e);
          for (var unspentRecord in utxos) {
            final txid = unspentRecord.transactionId;
            if (txids.contains(txid)) {
              try {
                await services.download.history.getAndSaveTransactions({txid});
              } catch (e) {
                /// so if this transaction is not found, we should remove the unspent
                await pros.unspents.remove(unspentRecord);
              }
            }
          }
        }
      }
    }
  }
}
