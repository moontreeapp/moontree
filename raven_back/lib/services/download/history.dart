import 'dart:async';
import 'package:quiver/iterables.dart';
import 'package:tuple/tuple.dart';
import 'package:raven_electrum/raven_electrum.dart';
import 'package:raven_back/streams/wallet.dart';
import 'package:raven_back/raven_back.dart';

class HistoryService {
  Set<String> downloaded = {};

  Future<bool> getHistories(Address address) async {
    void sendToStream(Iterable<String> txs) {
      streams.wallet.transactions.add(WalletExposureTransactions(
        address: address,
        transactionIds: txs,
      ));
    }

    void updateCounts(LeaderWallet leader) {
      leader.removeUnused(address.hdIndex, address.exposure);
      leader.updateHighestUsedIndex(address.hdIndex, address.exposure);
    }

    void updateCache(LeaderWallet leader) {
      leader.addUnused(address.hdIndex, address.exposure);
    }

    var client = streams.client.client.value;
    if (client == null) {
      return false;
    }
    // TODO: edge case to consider...
    // if a history is too long, don't error
    // will have to just not show all historic transactions...
    var histories = await client.getHistory(address.id);
    if (histories.isNotEmpty) {
      if (address.wallet is LeaderWallet) {
        updateCounts(address.wallet as LeaderWallet);
        print('${address.address} histories found!');
        sendToStream(histories.map((history) => history.txHash));
        if (address.hdIndex >=
            address.wallet!.getHighestSavedIndex(address.exposure)) {
          streams.wallet.deriveAddress.add(DeriveLeaderAddress(
              leader: address.wallet as LeaderWallet,
              exposure: address.exposure,
              justOne: true));
        }
      } else {
        sendToStream(histories.map((history) => history.txHash));
        sendToStream([]);
      }
    } else {
      if (address.wallet is LeaderWallet) {
        updateCache(address.wallet as LeaderWallet);
      }
      print('${address.address} not found!');
      sendToStream([]);
    }
    return true;
  }

  Future<bool> produceAddressOrBalance(List<Future<Null>> futures) async {
    var client = streams.client.client.value;
    if (client == null) {
      return false;
    }
    var allDone = true;
    for (var leader in res.wallets.leaders) {
      for (var exposure in [NodeExposure.Internal, NodeExposure.External]) {
        if (!services.wallet.leader.gapSatisfied(leader, exposure)) {
          allDone = false;
          print('deriving ${leader.id.substring(0, 4)} ${exposure.enumString}');
          streams.wallet.deriveAddress
              .add(DeriveLeaderAddress(leader: leader, exposure: exposure));
        }
      }
    }
    if (allDone) {
      //await Future.wait(futures);
      //futures.clear();
      //print('ALL DONE!');
      await saveDanglingTransactions(client);
      await services.balance.recalculateAllBalances();
      services.download.asset.allAdminsSubs();
      // remove vouts pointing to addresses we don't own?
    } else {
      print('NOT ALL DONE');
    }
    return allDone;
  }

  Future getAndSaveMempoolTransactions([RavenElectrumClient? client]) async {
    client = client ?? streams.client.client.value;
    if (client == null || res.transactions.mempool.isEmpty) return;
    await saveTransactions(
      [
        for (var transactionId in res.transactions.mempool.map((t) => t.id))
          await client.getTransaction(transactionId)
      ],
      client,
    );
    await services.balance.recalculateAllBalances();
  }

  /// when an address status change: make our historic tx data match blockchain
  Future saveTransactions(
    List<Tx> txs,
    RavenElectrumClient client, {
    bool saveVin = true,
  }) async {
    var futures = [
      for (var tx in txs)
        saveTransaction(tx, client, saveVin: saveVin, justReturn: true)
    ];
    var threes = await Future.wait<List<Set>>(futures);
    print(threes.length);

    //var items = {0: <Vin>{}, 1: <Vout>{}, 2: <Transaction>{}};
    for (var three in threes) {
      if (three.isNotEmpty) {
        if (three[2].isNotEmpty) {
          await res.transactions.saveAll(three[2] as Set<Transaction>);
        }
        if (three[0].isNotEmpty) {
          await res.vins.saveAll(three[0] as Set<Vin>);
        }
        if (three[1].isNotEmpty) {
          await res.vouts.saveAll(three[1] as Set<Vout>);
        }
        //if (items[2]!.isNotEmpty) {
        //  items[2]!.addAll(three[2] as Set<Transaction>);
        //}
        //if (items[0]!.isNotEmpty) {
        //  items[0]!.addAll(three[0] as Set<Vin>);
        //}
        //if (items[1]!.isNotEmpty) {
        //  items[1]!.addAll(three[1] as Set<Vout>);
        //}
      }
    }
    //print('ITEMS: ${items.length}, $items, ${items.length}');
    //if (items[2]!.isNotEmpty) {
    //  await res.transactions.saveAll(items[2]! as Set<Transaction>);
    //}
    //if (items[0]!.isNotEmpty) {
    //  await res.vins.saveAll(items[0]! as Set<Vin>);
    //}
    //if (items[1]!.isNotEmpty) {
    //  await res.vouts.saveAll(items[1]! as Set<Vout>);
    //}
    print('done saving');
  }

  /// don't need this for creating UTXO set anymore but...
  /// still need this for getting correct balances of some transactions...
  /// one more step - get all vins that have no corresponding vout (in the db)
  /// and get the vouts for them
  Future saveDanglingTransactions(RavenElectrumClient client) async {
    var txs =
        (res.vins.danglingVins.map((vin) => vin.voutTransactionId).toSet());
    print('GETTING DANGLING TRANSACTIONS: $txs');
    await getTransactions(txs, saveVin: false);
  }

  Future saveDanglingTransactionsFor(
    LeaderWallet leader,
    NodeExposure exposure,
  ) async {
    var client = streams.client.client.value;
    if (client == null) {
      return false;
    }

    //how? leader.vins?
    //var txs =
    //    (res.vins.danglingVins.map((vin) => vin.voutTransactionId).toSet());
    ////print('GETTING DANGLING TRANSACTIONS: $txs');
    //for (var txHash in txs) {
    //  await getTransaction(txHash, saveVin: false);
    //}
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
    if (security == null ||
        asset == null ||
        vout.scriptPubKey.type == 'reissue_asset') {
      if (['transfer_asset', 'reissue_asset']
          .contains(vout.scriptPubKey.type)) {
        value = utils.amountToSat(vout.scriptPubKey.amount);
        //if we have no record of it in res.securities...
        var assetRetrieved =
            await services.download.asset.get(symbol, vout: vout);
        if (assetRetrieved != null) {
          value = assetRetrieved.value;
          asset = assetRetrieved.asset;
          security = assetRetrieved.security;
        }
      } else if (vout.scriptPubKey.type == 'new_asset') {
        symbol = vout.scriptPubKey.asset!;
        value = utils.amountToSat(vout.scriptPubKey.amount);
        asset = Asset(
          symbol: symbol,
          metadata: vout.scriptPubKey.ipfsHash ?? '',
          satsInCirculation: value,
          divisibility: vout.scriptPubKey.units ?? 0,
          reissuable: vout.scriptPubKey.reissuable == 1,
          transactionId: tx.txid,
          position: vout.n,
        );
        security = Security(
          symbol: symbol,
          securityType: SecurityType.RavenAsset,
        );
        await res.assets.save(asset);
        await res.securities.save(security);
        streams.asset.added.add(asset);
      }
    }
    return Tuple3(value, security ?? res.securities.RVN, asset);
  }

  Future<Null>? getTransaction(
    String transactionId, {
    bool saveVin = true,
  }) {
    var client = streams.client.client.value;
    if (client == null) {
      return null;
    }
    // not already downloaded?
    if (!downloaded.contains(transactionId)) {
      downloaded.add(transactionId);
      print('downloading: $transactionId');
      var s = Stopwatch()..start();
      return client.getTransaction(transactionId).then((tx) async {
        print('download time: ${s.elapsed}');
        s = Stopwatch()..start();
        await saveTransaction(tx, client, saveVin: saveVin);
        print('saving   time: ${s.elapsed}');
      });
    } else {
      print('skipping: $transactionId');
    }
    return null;
  }

  Future<Null>? getTransactions(
    Iterable<String> transactionIds, {
    bool saveVin = true,
  }) async {
    var client = streams.client.client.value;
    if (client == null) {
      return null;
    }
    // filter out already downloaded
    print('b4 transactionIds: $transactionIds');
    transactionIds = transactionIds
        .where((transactionId) => !downloaded.contains(transactionId))
        .toSet();
    print('after transactionIds: $transactionIds, downloaded: $downloaded');
    downloaded.addAll(transactionIds);
    print('downloading: ${transactionIds.length}');
    var txs = <Tx>[];
    try {
      txs = await client.getTransactions(transactionIds);
      print('downloaded: ${txs.length}');
    } catch (e) {
      print('error caught $e');
      var futures = <Future<Tx>>[];
      for (var transactionId in transactionIds) {
        futures.add(client.getTransaction(transactionId));
      }
      txs = await Future.wait<Tx>(futures);
    }
    await saveTransactions(
      txs,
      client,
      saveVin: saveVin,
    );
    return null;
  }

  Future<List<Set>> saveTransaction(
    Tx tx,
    RavenElectrumClient client, {
    bool saveVin = true,
    bool justReturn = false,
  }) async {
    var newVins = <Vin>{};
    var newVouts = <Vout>{};
    var newTxs = <Transaction>{};
    print('parsing/saving: ${tx.txid}');
    if (saveVin) {
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
    }
    for (var vout in tx.vout) {
      if (vout.scriptPubKey.type == 'nullassetdata') continue;
      //if (tx.txid ==
      //    '7df22524d784b184fd5aaad900d638328c7cc3749f9f8b8c3ce648e80840494c') {
      //  print('tx');
      //}
      var vs = await handleAssetData(client, tx, vout);
      newVouts.add(Vout(
        transactionId: tx.txid,
        position: vout.n,
        type: vout.scriptPubKey.type,
        lockingScript: vs.item3 != null ? vout.scriptPubKey.hex : null,
        // TEST THIS -- redownload everything and verify that asset vouts have 0 rvnValue
        rvnValue: vs.item3 != null ? 0 : vs.item1,
        assetValue: vs.item3 == null
            ? null
            : utils.amountToSat(vout.scriptPubKey.amount),
        assetSecurityId: vs.item2.id,
        memo: vout.memo,
        assetMemo: vout.assetMemo,
        toAddress: vout.scriptPubKey.addresses?[0],
        // multisig - must detect if multisig...
        additionalAddresses: (vout.scriptPubKey.addresses?.length ?? 0) > 1
            ? vout.scriptPubKey.addresses!
                .sublist(1, vout.scriptPubKey.addresses!.length)
            : null,
      ));
      newTxs.add(Transaction(
        id: tx.txid,
        height: tx.height,
        confirmed: (tx.confirmations ?? 0) > 0,
        time: tx.time,
      ));
    }
    if (justReturn) {
      return [newVins, newVouts, newTxs];
    } else {
      await res.transactions.saveAll(newTxs);
      await res.vins.saveAll(newVins);
      await res.vouts.saveAll(newVouts);
    }
    return [{}];
  }
}
