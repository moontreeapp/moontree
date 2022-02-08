import 'dart:async';

import 'package:raven_back/streams/wallet.dart';
import 'package:raven_electrum/raven_electrum.dart';
import 'package:raven_back/raven_back.dart';
import 'package:tuple/tuple.dart';

class HistoryService {
  Future<bool> getHistories(Address address) async {
    var client = streams.client.client.value;
    if (client == null) {
      return false;
    }
    var histories = await client.getHistory(address.addressId);
    if (histories.isNotEmpty) {
      streams.address.history.add(histories.map((history) => history.txHash));
      // if we had no history, and now we found some... derive a new address
      if (address.wallet is LeaderWallet && address.vouts.isEmpty) {
        streams.wallet.deriveAddress.add(DeriveLeaderAddress(
          leader: address.wallet as LeaderWallet,
          exposure: address.exposure,
        ));
      }
    } else {
      streams.address.empty.add(address);
    }
    return true;
  }

  Future<bool> getTransactions(Iterable<String> histories) async {
    var client = streams.client.client.value;
    if (client == null) {
      return false;
    }
    var txs = <Tx>[];
    for (var txHash in histories) {
      // we need to look into this on change of wallet from mainnet to testnet
      // or even on new password or change or removal do we really need to
      // download them all again? could we merely change the wallet id that the
      // addresses point to, perhaps, so that this is valid, we never have to
      // redownload individaul transactions again?
      if ((res.transactions.primaryIndex.getOne(txHash) == null ||
          res.transactions.mempool
              .map((t) => t.transactionId)
              .contains(txHash))) {
        // not already downloaded...
        txs.add(await client.getTransaction(txHash));
      } else {
        print('skipping $txHash');
      }
    }
    await saveTransactions(txs, client);
    return true;
  }

  // if all the leader wallets have their empty addresses gaps satisfied,
  // you're done! trigger balance calculation, else trigger derive address.
  Future<bool> produceAddressOrBalance() async {
    var client = streams.client.client.value;
    if (client == null) {
      return false;
    }
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
  Future saveTransactions(List<Tx> txs, RavenElectrumClient client,
      {bool saveVin = true}) async {
    /// save all vins, vouts and transactions
    var newVins = <Vin>{};
    var newVouts = <Vout>{};
    var newTxs = <Transaction>{};
    for (var tx in txs) {
      print('downloading  tx : ${tx.txid.substring(0, 5)}');
      if (saveVin) {
        for (var vin in tx.vin) {
          //print('downloading  vin: ${tx.txid.substring(0, 5)}');
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
      }
      for (var vout in tx.vout) {
        //print('downloading  vout: ${tx.txid.substring(0, 5)}');
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
          assetValue: utils.amountToSat(vout.scriptPubKey.amount,
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
      //print('done with tx: ${tx.txid.substring(0, 5)}');
    }

    //await res.vins.removeAll(existingVins.difference(newVins));
    //await res.vouts.removeAll(existingVouts.difference(newVouts));

    // must await?
    await res.transactions.saveAll(newTxs);
    await res.vins.saveAll(newVins);
    await res.vouts.saveAll(newVouts);
  }

  /// one more step - get all vins that have no corresponding vout (in the db)
  /// and get the vouts for them
  Future saveDanglingTransactions(RavenElectrumClient client) async {
    var txs =
        (res.vins.danglingVins.map((vin) => vin.voutTransactionId).toSet());
    print('GETTING DANGLING TRANSACTIONS: $txs');
    for (var txHash in txs) {
      await getTransaction(txHash, saveVin: false);
    }
  }

  /// we capture securities here. if it's one we've never seen,
  /// get it's metadata and save it in the securities reservoir.
  /// return value and security to be saved in vout.
  Future<Tuple3<int, Security, Asset?>> handleAssetData(
    RavenElectrumClient client,
    Tx tx,
    TxVout vout,
  ) async {
    var symbol = vout.scriptPubKey.asset ?? 'RVN';
    var value = vout.valueSat;
    var security = res.securities.bySymbolSecurityType
        .getOne(symbol, SecurityType.RavenAsset);
    var asset = res.assets.bySymbol.getOne(symbol);

    if (security == null) {
      if (vout.scriptPubKey.type == 'transfer_asset') {
        value = utils.amountToSat(vout.scriptPubKey.amount,
            divisibility: vout.scriptPubKey.units ?? 8);
        //if we have no record of it in res.securities...
        var meta = await client.getMeta(symbol);
        if (meta != null) {
          value = utils.amountToSat(vout.scriptPubKey.amount,
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
        value = utils.amountToSat(vout.scriptPubKey.amount,
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

  Future<bool> getTransaction(String transactionId,
      {bool saveVin = true}) async {
    var client = streams.client.client.value;
    if (client == null) {
      return false;
    }
    // not already downloaded?
    if ((res.transactions.primaryIndex.getOne(transactionId) == null ||
        res.transactions.mempool
            .map((t) => t.transactionId)
            .contains(transactionId))) {
      print('downloading: $transactionId');
      await saveTransaction(await client.getTransaction(transactionId), client,
          saveVin: saveVin);
    } else {
      print('skipping $transactionId');
    }
    return true;
  }

  Future saveTransaction(Tx tx, RavenElectrumClient client,
      {bool saveVin = true}) async {
    print('parsing/saving: ${tx.txid}');
    for (var vin in tx.vin) {
      if (saveVin) {
        if (vin.txid != null && vin.vout != null) {
          await res.vins.save(Vin(
            transactionId: tx.txid,
            voutTransactionId: vin.txid!,
            voutPosition: vin.vout!,
          ));
        } else if (vin.coinbase != null && vin.sequence != null) {
          await res.vins.save(Vin(
            transactionId: tx.txid,
            voutTransactionId: vin.coinbase!,
            voutPosition: vin.sequence!,
            isCoinbase: true,
          ));
        }
      }
    }
    for (var vout in tx.vout) {
      if (vout.scriptPubKey.type == 'nulldata') continue;
      var vs = await handleAssetData(client, tx, vout);
      await res.vouts.save(Vout(
        transactionId: tx.txid,
        rvnValue: vs.item1,
        position: vout.n,
        memo: vout.memo,
        type: vout.scriptPubKey.type,
        toAddress: vout.scriptPubKey.addresses![0],
        assetSecurityId: vs.item2.securityId,
        assetValue: utils.amountToSat(vout.scriptPubKey.amount,
            divisibility:
                vs.item3?.divisibility ?? vout.scriptPubKey.units ?? 8),
        // multisig - must detect if multisig...
        additionalAddresses: (vout.scriptPubKey.addresses?.length ?? 0) > 1
            ? vout.scriptPubKey.addresses!
                .sublist(1, vout.scriptPubKey.addresses!.length)
            : null,
      ));
      await res.transactions.save(Transaction(
        transactionId: tx.txid,
        height: tx.height,
        confirmed: (tx.confirmations ?? 0) > 0,
        time: tx.time,
      ));
    }
  }
}
