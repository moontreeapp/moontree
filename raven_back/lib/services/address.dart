import 'dart:async';

import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'package:raven/raven.dart';
import 'package:tuple/tuple.dart';

class AddressService {
  /// when an address status change: make our historic tx data match blockchain
  Future getAndSaveTransactions(
    List<Address> changedAddresses,
    RavenElectrumClient client,
  ) async {
    for (var changedAddress in changedAddresses) {
      // erase all vins and vouts not pulled. (or just remove all first - the simple way).
      ///await vins.removeAll(vins.byAddress.getAll(addressId)); // broken join
      ///await vouts.removeAll(vouts.byAddress.getAll(changedAddress.address));

      /// never purge tx (unless theres a reorg or something)
      /// transactions are not associated with addresses directly
      //var removeTransactions = transactions.byScripthash.getAll(addressId);
      //await transactions.removeAll(removeTransactions);

      // get a list of all historic transaction ids assicated with this address
      // ignore: omit_local_variable_types
      List<ScripthashHistory> histories =
          await client.getHistory(changedAddress.addressId);

      /// get all transactions - batch silently fails on some txHashes such as
      /// 9c0175c81d47fb3e8d99ec5a7b7f901769185682ebad31a8fcec9f77c656a97f
      /// (or one in it's batch)
      // ignore: omit_local_variable_types
      List<Tx> txs = [
        for (var txHash in histories.map((history) => history.txHash))
          if (transactions.primaryIndex.getOne(txHash) == null)

            /// if we should pause for cost purposes we'd have to do it here.
            /// use .our_stats to find out

            /// get missing transaction
            await client.getTransaction(txHash)
      ];

      /// save all vins, vouts and transactions
      var newVins = <Vin>{};
      var newVouts = <Vout>{};
      var newTxs = <Transaction>{};
      for (var tx in txs) {
        for (var vin in tx.vin) {
          if (vin.txid != null && vin.vout != null) {
            newVins.add(Vin(
              txId: tx.txid,
              voutTxId: vin.txid!,
              voutPosition: vin.vout!,
            ));
          } else if (vin.coinbase != null && vin.sequence != null) {
            newVins.add(Vin(
              txId: tx.txid,
              voutTxId: vin.coinbase!,
              voutPosition: vin.sequence!,
              isCoinbase: true,
            ));
          }
        }
        for (var vout in tx.vout) {
          if (vout.scriptPubKey.type == 'nulldata') continue;
          var vs = await handleAssetData(client, tx, vout);
          newVouts.add(Vout(
            txId: tx.txid,
            rvnValue: vs.item1,
            position: vout.n,
            memo: vout.memo,
            type: vout.scriptPubKey.type,
            toAddress: vout.scriptPubKey.addresses![0],
            assetSecurityId: vs.item2.securityId,
            assetValue: vout.scriptPubKey.amount,
            // multisig - must detect if multisig...
            additionalAddresses: (vout.scriptPubKey.addresses?.length ?? 0) > 1
                ? vout.scriptPubKey.addresses!
                    .sublist(1, vout.scriptPubKey.addresses!.length)
                : null,
          ));
        }

        /// might as well just save them all  - maybe avoiding saving them all
        /// can save some time, but then you have to also check confirmations
        /// and see if anything else changed. meh, just save them all for now.
        newTxs.add(Transaction(
          txId: tx.txid,
          height: tx.height,
          confirmed: (tx.confirmations ?? 0) > 0,
          time: tx.time,
        ));
      }

      //await vins.removeAll(existingVins.difference(newVins));
      //await vouts.removeAll(existingVouts.difference(newVouts));

      // must await?
      await transactions.saveAll(newTxs);
      await vins.saveAll(newVins);
      await vouts.saveAll(newVouts);
    }

    /// one more step - get all vins that have no corresponding vout (in the db)
    /// and get the vouts for them
    var finalVouts = <Vout>[];
    var finalTxs = <Transaction>[];
    // ignore: omit_local_variable_types
    var myVins = vins.danglingVins.map((vin) => vin.voutTxId);
    // ignore: omit_local_variable_types
    List<Tx> txs = [
      for (var txHash in myVins) await client.getTransaction(txHash)
    ];

    for (var tx in txs) {
      for (var vout in tx.vout) {
        if (vout.scriptPubKey.type == 'nulldata') continue;
        var vs = await handleAssetData(client, tx, vout);
        finalVouts.add(Vout(
          txId: tx.txid,
          rvnValue: vs.item1,
          position: vout.n,
          memo: vout.memo,
          type: vout.scriptPubKey.type,
          toAddress: vout.scriptPubKey.addresses![0],
          assetSecurityId: vs.item2.securityId,
          assetValue: vout.scriptPubKey.amount,
          // multisig - must detect if multisig...
          additionalAddresses: (vout.scriptPubKey.addresses?.length ?? 0) > 1
              ? vout.scriptPubKey.addresses!
                  .sublist(1, vout.scriptPubKey.addresses!.length)
              : null,
        ));
      }

      /// might as well just save them all  - maybe avoiding saving them all
      /// can save some time, but then you have to also check confirmations
      /// and see if anything else changed. meh, just save them all for now.
      finalTxs.add(Transaction(
        txId: tx.txid,
        height: tx.height,
        confirmed: (tx.confirmations ?? 0) > 0,
        time: tx.time,
      ));
    }
    await transactions.saveAll(finalTxs);
    await vouts.saveAll(finalVouts);
  }

  /// we capture securities here. if it's one we've never seen,
  /// get it's metadata and save it in the securities reservoir.
  /// return value and security to be saved in vout.
  Future<Tuple2<int, Security>> handleAssetData(
      RavenElectrumClient client, Tx tx, TxVout vout) async {
    var symbol = 'RVN';
    var value = vout.valueSat;
    var security;
    if (vout.scriptPubKey.type == 'transfer_asset') {
      symbol = vout.scriptPubKey.asset!;
      value = vout.scriptPubKey.amount!;
      security = securities.bySymbolSecurityType
          .getOne(symbol, SecurityType.RavenAsset);
      //if we have no record of it in securities...
      if (security == null) {
        var meta = await client.getMeta(symbol);
        if (meta != null) {
          security = Security(
            symbol: meta.symbol,
            securityType: SecurityType.RavenAsset,
            satsInCirculation: meta.satsInCirculation,
            precision: meta.divisions,
            reissuable: meta.reissuable == 1,
            metadata: (await client.getTransaction(meta.source.txHash))
                .vout[meta.source.txPos]
                .scriptPubKey
                .ipfsHash,
            txId: meta.source.txHash,
            position: meta.source.txPos,
          );
          await securities.save(security);
        }
      }
    } else if (vout.scriptPubKey.type == 'new_asset') {
      symbol = vout.scriptPubKey.asset!;
      value = vout.scriptPubKey.amount!;
      security = Security(
        symbol: symbol,
        securityType: SecurityType.RavenAsset,
        satsInCirculation: value, //?? as sats?
        precision: vout.scriptPubKey.units,
        reissuable: vout.scriptPubKey.reissuable == 1,
        metadata: vout.scriptPubKey.ipfsHash,
        txId: tx.txid,
        position: vout.n,
      );
      await securities.save(security);
    }
    return Tuple2(value, security ?? securities.RVN);
  }
}
