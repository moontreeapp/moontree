import 'dart:async';

import 'package:raven_back/streams/wallet.dart';
import 'package:raven_electrum/raven_electrum.dart';
import 'package:raven_back/raven_back.dart';
import 'package:tuple/tuple.dart';

class HistoryService {
  Set<String> unretrieved = {};
  Set<String> retrieving = {};
  Set<String> retrieved = {};

  Future<bool> getHistories(Address address) async {
    var client = streams.client.client.value;
    if (client == null) {
      return false;
    }

    var histories = await client.getHistory(address.addressId);

    if (histories.isNotEmpty) {
      unretrieved.addAll(histories.map((h) => h.txHash));
      var wallet = address.wallet;
      if (wallet is LeaderWallet && address.vouts.isEmpty) {
        var found = [
          for (var item in [
            '681c62266f6dc3c1c16ba5024c5bb875c627ab89815fd61f689519e06036832b',
            'f585233ccb19f93912c094e66d5681b73a4adcf3db50c7455e5d9b2a724b2345',
            '47f0fc510a930c56797d5bf2ed574e9a7d67153d8e34e6b342af6947d0efdddf',
            'e80568e961b4a978dcf5ab533638505823bbb83bbea2c742afb35f6b22ff96b6',
            'c512010a793a7a4296e1a34e1c11b94441226f602cf57c9b56d3a20307f02b41',
            'fe08c278ad54f3fdcc35aa6d05de7b955f22d842d9ef75a501fa82aa68dbc178',
            '00111be079656f15bc63afa843860f37e0ecbc6e374c2e35c11fac6eff9cb810',
            '5fd5dc8fbb486404feb24762a838c09131d225b3547b9fa318920d1593591139',
            'ef1be6f06025e6bd8d7e8319003296e168068ce9d08e6efc1612c06fcb13c330',
            '14de222d2825ec8e187e4d8c2785bdf26663d6d8e9f5475cb97a5e6376a64d56',
            '24031e0a46ae015cdb58d53dfb8910207d53b6a061387ffd2368730533043f3e',
            '6b5d00227fc75b590d693877a32ecce55664fd851238de1cfa3fae5ce1362862',
            '17b798480e340ae639c23a036ee39d61784b4418ca3d40c43ae2e7c9728e76e2',
            '6ef14bbacb9dc343eb9cde1f2a311ae787231613fc6ae863cec11752a56c3308',
            '53572c6054e8c00b847ed19682e487b1a44b4a28c3a6001bd84473db1c671044',
            '5cdde1dc17f820320011ec648272237322e1cde48e62158b3cb56999c5aba0e8',
            '7217229e9fa0e668aebc4d1478ab69320ee7d9b6ca6357c30a38b4b4a89a0c0d',
            'c88fe87a5df1f8fac0ba929a7021038d66947fd4aabef2368eb7aa21aea2c3c5',
            '9b64eb258a4352a68c4ce98cbbadddcbbcb285c422f7f9f97ed4b826d0a387d7',
          ])
            for (var thing in histories)
              if (item == thing.txHash) item
        ];
        if (found.isNotEmpty) {
          print(found);
        }
        print(address.address);
        for (var item in histories) {
          print(item);
        }
        // if we had no history, and now we found some... derive a new address
        streams.wallet.deriveAddress.add(DeriveLeaderAddress(
          leader: wallet,
          exposure: address.exposure,
        ));
      }
      streams.address.history.add(histories);
    } else {
      streams.address.empty.add(true);
    }
    return true;
  }

  Future<bool> getTransactions(List<ScripthashHistory> histories) async {
    var client = streams.client.client.value;
    if (client == null) {
      return false;
    }
    var txs = <Tx>[];
    for (var txHash in histories.map((history) => history.txHash)) {
      // we need to look into this on change of wallet from mainnet to testnet
      // or even on new password or change or removal do we really need to
      // download them all again? could we merely change the wallet id that the
      // addresses point to, perhaps, so that this is valid, we never have to
      // redownload individaul transactions again?
      if ((res.transactions.primaryIndex.getOne(txHash) == null ||
              res.transactions.mempool
                  .map((t) => t.transactionId)
                  .contains(txHash)) &&
          !(retrieving.contains(txHash) || retrieved.contains(txHash))) {
        // not already downloaded...
        txs.add(await client.getTransaction(txHash));
      } else {
        print('skipping ${txHash}');
      }
      unretrieved.remove(txHash);
      retrieving.add(txHash);
    }
    await saveTransactions(txs, client);
    retrieving.removeAll(txs.map((t) => t.txid));
    retrieved.addAll(txs.map((t) => t.txid));

    return true;
  }

  // if all the leader wallets have their empty addresses gaps satisfied,
  // you're done! trigger balance calculation, else trigger derive address.
  Future<bool> produceAddressOrBalance() async {
    var client = streams.client.client.value;
    if (client == null) {
      return false;
    }

    /// we should add to backlog and let the leader waiter take care of those
    /// if the cipher isn't currently available it should be since we obviously
    /// just used it to make an address, most likely, but maybe there are edge
    /// cases, so we should do the check anyway.
    //print('unretrieved $unretrieved');
    //print('retrieving $retrieving');
    //print('retrieved $retrieved');
    //print(
    //    'DATA ${res.transactions.data.where((e) => retrieved.contains(e.transactionId))}');
    //print(
    //    'PROVEN ${retrieved.where((e) => !res.transactions.data.map((ee) => ee.transactionId).contains(e))}');

    //if (unretrieved.isNotEmpty || retrieving.isNotEmpty) {
    //  return false;
    //}
    var allDone = true;
    for (var leader in res.wallets.leaders) {
      for (var exposure in [NodeExposure.Internal, NodeExposure.External]) {
        if (!services.wallet.leader.gapSatisfied(leader, exposure)) {
          allDone = false;
          streams.wallet.deriveAddress
              .add(DeriveLeaderAddress(leader: leader, exposure: exposure));
        }
      }
    }
    if (allDone) {
      await saveDanglingTransactions(client);
      await services.balance.recalculateAllBalances();
    }
    return allDone;
  }

  Future getAndSaveMempoolTransactions([RavenElectrumClient? client]) async {
    client = client ?? streams.client.client.value;
    if (client == null) return;
    await saveTransactions(
      [
        for (var transactionId
            in res.transactions.mempool.map((t) => t.transactionId))
          await client.getTransaction(transactionId)
      ],
      client,
    );
    await services.balance.recalculateAllBalances();
  }

  /// when an address status change: make our historic tx data match blockchain
  Future saveTransactions(List<Tx> txs, RavenElectrumClient client) async {
    /// save all vins, vouts and transactions
    var newVins = <Vin>{};
    var newVouts = <Vout>{};
    var newTxs = <Transaction>{};
    for (var tx in txs) {
      print('downloading  tx : ${tx.txid.substring(0, 5)}');
      for (var vin in tx.vin) {
        print('downloading  vin: ${tx.txid.substring(0, 5)}');
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
        print('downloading  vout: ${tx.txid.substring(0, 5)}');
        if (vout.scriptPubKey.type == 'nulldata') continue;
        var vs = await handleAssetData(client, tx, vout);
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
      print('done with tx: ${tx.txid.substring(0, 5)}');
    }

    //await res.vins.removeAll(existingVins.difference(newVins));
    //await res.vouts.removeAll(existingVouts.difference(newVouts));

    // must await?
    await res.transactions.saveAll(newTxs);
    await res.vins.saveAll(newVins);
    await res.vouts.saveAll(newVouts);
  }

  /// when an address status change: make our historic tx data match blockchain
  Future saveDanglingTransactions(RavenElectrumClient client) async {
    print('GETTING DANGLING TRANSACTIONS');

    /// one more step - get all vins that have no corresponding vout (in the db)
    /// and get the vouts for them
    var finalVouts = <Vout>[];
    var finalTxs = <Transaction>[];
    // ignore: omit_local_variable_types
    var myVins =
        List.from(res.vins.danglingVins.map((vin) => vin.voutTransactionId));
    for (var tx in [
      for (var txHash in myVins) await client.getTransaction(txHash)
    ]) {
      for (var vout in tx.vout) {
        if (vout.scriptPubKey.type == 'nulldata') continue;
        var vs = await handleAssetData(client, tx, vout);
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
    await res.transactions.saveAll(finalTxs);
    await res.vouts.saveAll(finalVouts);
  }

  /// we capture securities here. if it's one we've never seen,
  /// get it's metadata and save it in the securities reservoir.
  /// return value and security to be saved in vout.
  Future<Tuple3<int, Security, Asset?>> handleAssetData(
    RavenElectrumClient client,
    Tx tx,
    TxVout vout,
  ) async {
    print('HANDLEASSET ${vout.scriptPubKey.asset}');
    var symbol = vout.scriptPubKey.asset ?? 'RVN';
    var value = vout.valueSat;
    var security = res.securities.bySymbolSecurityType
        .getOne(symbol, SecurityType.RavenAsset);
    var asset = res.assets.bySymbol.getOne(symbol);
    if (security == null) {
      if (vout.scriptPubKey.type == 'transfer_asset') {
        //print('ASSET-=----------');
        //print(symbol);
        value = amountToSat(vout.scriptPubKey.amount,
            divisibility: vout.scriptPubKey.units ?? 8);
        //print(value);
        //if we have no record of it in res.securities...
        var meta = await client.getMeta(symbol);
        //print(meta);
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
          await res.securities.save(security);
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
        await res.securities.save(security);
      }
    }
    return Tuple3(value, security ?? res.securities.RVN, asset);
  }
}
