import 'dart:async';

import 'package:raven_electrum/raven_electrum.dart';
import 'package:raven_back/raven_back.dart';
import 'package:tuple/tuple.dart';

class AddressService {
  Set<String> unretrieved = {};
  Set<String> retrieved = {};

  /// when an address status change: pull txs match blockchain
  Future getAndSaveTransactionsByAddresses(
    Address address,
    RavenElectrumClient client,
  ) async {
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
        await client.getHistory(address.addressId);

    /// get all transactions - batch silently fails on some txHashes such as
    /// 9c0175c81d47fb3e8d99ec5a7b7f901769185682ebad31a8fcec9f77c656a97f
    /// (or one in it's batch)
    // ignore: omit_local_variable_types
    await saveTransactions([
      for (var txHash in histories.map((history) => history.txHash))

        /// this successfully reduced download redundancy but if things
        /// downloaded in a particular order, it caused the error of not
        /// downloading every transaction we needed, somehow. So this
        /// condition has been removed.
        //if (transactions.primaryIndex.getOne(txHash) == null ||
        //    transactions.primaryIndex.getOne(txHash)!.vins.isEmpty)
        await client.getTransaction(txHash)
    ], client);
    unretrieved.remove(address.addressId);
    retrieved.add(address.addressId);

    /// this condition marks the end of the external loop: after we have
    /// generated and looked for all transactions for those addresses...
    /// pull vouts for vins that don't have corresponding vouts and
    /// calculate all balances.
    await triggerDeriveOrBalance(client);
  }

  // if all the leader wallets have their empty addresses gaps satisfied,
  // you're done! trigger balance calculation, else trigger derive address.
  Future triggerDeriveOrBalance([RavenElectrumClient? client]) async {
    /// we should add to backlog and let the leader waiter take care of those
    /// if the cipher isn't currently available it should be since we obviously
    /// just used it to make an address, most likely, but maybe there are edge
    /// cases, so we should do the check anyway.
    client = client ?? streams.client.client.value;
    if (unretrieved.isEmpty) {
      var allDone = true;
      for (var leader in wallets.leaders) {
        for (var exposure in [NodeExposure.Internal, NodeExposure.External]) {
          if (!services.wallet.leader.gapSatisfied(leader, exposure)) {
            if (ciphers.primaryIndex.getOne(leader.cipherUpdate) != null) {
              allDone = false;
              var derived = services.wallet.leader.deriveMoreAddresses(
                leader,
                exposures: [exposure],
              );
              for (var addressId
                  in derived.map((address) => address.addressId)) {
                if (!services.address.retrieved.contains(addressId)) {
                  services.address.unretrieved.add(addressId);
                }
              }
              services.client.subscribe.toExistingAddresses();
              //return; // break
            } else {
              services.wallet.leader.backlog.add(leader);
            }
          }
        }
      }
      if (allDone) {
        await saveDanglingTransactions(client!);
        await services.balance.recalculateAllBalances();
      }
    }
  }

  Future getAndSaveMempoolTransactions([RavenElectrumClient? client]) async {
    client = client ?? streams.client.client.value;
    if (client == null) return;
    await saveTransactions(
      [
        for (var transactionId
            in transactions.mempool.map((t) => t.transactionId))
          await client.getTransaction(transactionId)
      ],
      client,
    );
    await services.balance.recalculateAllBalances();
  }

  /// when an address status change: make our historic tx data match blockchain
  Future saveTransactions(List<Tx> txs, RavenElectrumClient client) async {
    // why called twice?

    /// save all vins, vouts and transactions
    var newVins = <Vin>{};
    var newVouts = <Vout>{};
    var newTxs = <Transaction>{};
    for (var tx in txs) {
      for (var vin in tx.vin) {
        if (vin.txid != null && vin.vout != null) {
          newVins.add(Vin(
            transactionId: tx.txid,
            voutTransactionId: vin.txid!,
            voutPosition: vin.vout!,
          ));
        } else if (vin.coinbase != null && vin.sequence != null) {
          newVins.add(Vin(
            transactionId: tx.txid,
            voutTransactionId: vin.coinbase!,
            voutPosition: vin.sequence!,
            isCoinbase: true,
          ));
        }
      }
      for (var vout in tx.vout) {
        if (vout.scriptPubKey.type == 'nulldata') continue;
        var vs = await handleAssetData(client, tx, vout);
        print('GETTING STUFF for NEW   $vs');
        print(amountToSat(vout.scriptPubKey.amount,
            divisibility:
                vs.item3?.divisibility ?? vout.scriptPubKey.units ?? 8));
        print(vout.scriptPubKey.amount);
        print(vout.scriptPubKey.units);
        print(vs.item3);
        newVouts.add(Vout(
          transactionId: tx.txid,
          rvnValue: vs.item1,
          position: vout.n,
          memo: vout.memo,
          type: vout.scriptPubKey.type,
          toAddress: vout.scriptPubKey.addresses![0],
          assetSecurityId: vs.item2.securityId,
          assetValue: amountToSat(vout.scriptPubKey.amount,
              divisibility:
                  vs.item3?.divisibility ?? vout.scriptPubKey.units ?? 8),
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
        transactionId: tx.txid,
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

  /// when an address status change: make our historic tx data match blockchain
  Future saveDanglingTransactions(
    RavenElectrumClient client,
  ) async {
    /// one more step - get all vins that have no corresponding vout (in the db)
    /// and get the vouts for them
    var finalVouts = <Vout>[];
    var finalTxs = <Transaction>[];
    // ignore: omit_local_variable_types
    var myVins =
        List.from(vins.danglingVins.map((vin) => vin.voutTransactionId));
    // ignore: omit_local_variable_types
    List<Tx> txs = [
      for (var txHash in myVins) await client.getTransaction(txHash)
    ];

    for (var tx in txs) {
      for (var vout in tx.vout) {
        if (vout.scriptPubKey.type == 'nulldata') continue;
        var vs = await handleAssetData(client, tx, vout);
        /*
        [Vout(transactionId: 6984d492be101d0e76838369112f65e74472357cbd5d9820571e124032eeedf2,
          rvnValue: 1000000000,
          position: 3,
          memo: ,
          type: new_asset,
          toAddress: n1jgWeBioupbvBhNhCoa15tK5Sng3i4DLx,
          assetSecurityId: MOONTREE0:RavenAsset,
          assetValue: 1000,
          additionalAddresses: null),
        Vout(transactionId: af288ad6f644f3123c5828f6cccc42e2e38c1acf88e3eb2f1e13732fea2f93ae,
          rvnValue: 1000000000,
          position: 1,
          memo: ,
          type: transfer_asset,
          toAddress: mqTDFJsCiBaDY5UYupbZgoJbgDk3s9ApRt,
          assetSecurityId: MOONTREE0:RavenAsset,
          assetValue: 10,                                       ???????????????????
          additionalAddresses: null)]
        
        notice new asset has it as correct satioshi, but existing doesn't... 
        */
        print('GETTING STUFF for final $vs');
        print(amountToSat(vout.scriptPubKey.amount,
            divisibility:
                vout.scriptPubKey.units ?? vs.item3?.divisibility ?? 8));
        print(vout.scriptPubKey.amount);
        print(vout.scriptPubKey.units);
        print(vs.item3);

        finalVouts.add(Vout(
          transactionId: tx.txid,
          rvnValue: vs.item1,
          position: vout.n,
          memo: vout.memo,
          type: vout.scriptPubKey.type,
          toAddress: vout.scriptPubKey.addresses![0],
          assetSecurityId: vs.item2.securityId,
          assetValue: amountToSat(vout.scriptPubKey.amount,
              divisibility:
                  vs.item3?.divisibility ?? vout.scriptPubKey.units ?? 8),
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
        transactionId: tx.txid,
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
  Future<Tuple3<int, Security, Asset?>> handleAssetData(
    RavenElectrumClient client,
    Tx tx,
    TxVout vout,
  ) async {
    var symbol = 'RVN';
    var value = vout.valueSat;
    var security =
        securities.bySymbolSecurityType.getOne(symbol, SecurityType.RavenAsset);
    var asset = assets.bySymbol.getOne(symbol);
    if (security == null) {
      if (vout.scriptPubKey.type == 'transfer_asset') {
        symbol = vout.scriptPubKey.asset!;
        value = amountToSat(vout.scriptPubKey.amount,
            divisibility: vout.scriptPubKey.units ?? 8);
        //if we have no record of it in securities...
        var meta = await client.getMeta(symbol);
        if (meta != null) {
          value = amountToSat(vout.scriptPubKey.amount,
              divisibility: vout.scriptPubKey.units ?? meta.divisions);
          asset = Asset(
            symbol: meta.symbol,
            metadata: (await client.getTransaction(meta.source.txHash))
                    .vout[meta.source.txPos]
                    .scriptPubKey
                    .ipfsHash ??
                '',
            satsInCirculation: meta.satsInCirculation,
            divisibility: meta.divisions,
            reissuable: meta.reissuable == 1,
            transactionId: meta.source.txHash,
            position: meta.source.txPos,
          );
          streams.asset.added.add(asset);
          security = Security(
            symbol: meta.symbol,
            securityType: SecurityType.RavenAsset,
          );
          await securities.save(security);
        }
      } else if (vout.scriptPubKey.type == 'new_asset') {
        symbol = vout.scriptPubKey.asset!;
        value = amountToSat(vout.scriptPubKey.amount,
            divisibility: vout.scriptPubKey.units ?? 0);
        asset = Asset(
          symbol: symbol,
          metadata: vout.scriptPubKey.ipfsHash ?? '',
          satsInCirculation: value,
          divisibility: vout.scriptPubKey.units ?? 0,
          reissuable: vout.scriptPubKey.reissuable == 1,
          transactionId: tx.txid,
          position: vout.n,
        );
        streams.asset.added.add(asset);
        security = Security(
          symbol: symbol,
          securityType: SecurityType.RavenAsset,
        );
        await securities.save(security);
      }
    }
    return Tuple3(value, security ?? securities.RVN, asset);
  }
}
