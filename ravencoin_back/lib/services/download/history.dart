import 'dart:async';
import 'package:tuple/tuple.dart';
import 'package:ravencoin_electrum/ravencoin_electrum.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

class HistoryService {
  bool busy = false;
  int calledAllDoneProcess = 0; // used to hide transactions while downloading
  Future aggregatedDownloadProcess(List<Address> addresses) async {
    busy = true;
    var txHashes = (await getHistories(addresses)).toSet();
    var txs = await grabTransactions(txHashes);
    await saveThese([for (var tx in txs) await parseTx(tx)]);
    busy = false;
  }

  /// never called
  //Future<List<List<String>>> getHistories(List<Address> addresses) async {
  //  try {
  //    var listOfLists = await services.client.api.getHistories(addresses);
  //    return [
  //      for (var x in listOfLists) x.map((history) => history.txHash).toList()
  //    ];
  //  } catch (e) {
  //    try {
  //      var txIds = <List<String>>[];
  //      for (var address in addresses) {
  //        var historiesItem;
  //        try {
  //          historiesItem = (await services.client.api.getHistory(address))
  //              .map((history) => history.txHash)
  //              .toList();
  //        } catch (e) {
  //          historiesItem = [];
  //        }
  //        txIds.add(historiesItem);
  //      }
  //      return txIds;
  //    } catch (e) {
  //      return [for (var _ in addresses) []];
  //    }
  //  }
  //}

  Future<List<String>> getHistories(List<Address> addresses) async {
    try {
      var listOfLists = await services.client.api.getHistories(addresses);
      return [
        for (var x in listOfLists) x.map((history) => history.txHash).toList()
      ].expand((e) => e).toList();
    } catch (e) {
      try {
        var txIds = <List<String>>[];
        for (var address in addresses) {
          var historiesItem;
          try {
            historiesItem = (await services.client.api.getHistory(address))
                .map((history) => history.txHash)
                .toList();
          } catch (e) {
            historiesItem = [];
          }
          txIds.add(historiesItem);
        }
        return txIds.expand((e) => e).toList();
      } catch (e) {
        return [];
      }
    }
  }

  /// called during address subscription
  Future<List<String>> getHistory(Address address) async {
    try {
      final t = (await services.client.api.getHistory(address))
          .map((history) => history.txHash)
          .toList();
      return t;
    } catch (e) {
      return [];
    }
  }

  Future getAndSaveMempoolTransactions() async {
    var x = pros.transactions.mempool.map((t) => t.id).toSet();
    if (x.isNotEmpty) {
      await getAndSaveTransactions(x);
    }
  }

  Future getAndSaveTransactions(
    Set<String> txIds, {
    bool saveVin = true,
    bool saveVout = true,
  }) async {
    await getTransactions(txIds, saveVin: saveVin, saveVout: saveVout);
    print('DONE!');
    //busy = true;
    //await saveTransactions(
    //  [
    //    for (var transactionId in txIds)
    //      await services.client.api.getTransaction(transactionId)
    //  ],
    //  saveVin: saveVin,
    //  saveVout: saveVout,
    //);
    //busy = false;
  }

  Future allDoneProcess() async {
    busy = true;
    calledAllDoneProcess += 1;
    await saveDanglingTransactions();
    busy = false;
  }

  /// don't need this for creating UTXO set anymore but...
  /// still need this for getting correct balances of some transactions...
  /// one more step - get all vins that have no corresponding vout (in the db)
  /// and get the vouts for them
  Future saveDanglingTransactions() async {
    final txs = pros.vins.dangling.map((vin) => vin.voutTransactionId).toSet();
    await getTransactions(
      filterOutPreviouslyDownloaded(txs),
      saveVin: false,
      saveVout: true,
    );

    /// this really doesn't seem necessary because we grab it when we pull.
    // make sure you have all the vouts that you need for transactions according
    // to the unspents:
    //await getTransactions(
    //  filterOutPreviouslyDownloaded(
    //      pros.unspents.records.map((e) => e.transactionId).toSet()),
    //  saveVin: false, //
    //  saveVout: true,
    //);
  }

  Iterable<String> filterOutPreviouslyDownloaded(
    Iterable<String> transactionIds,
  ) =>
      transactionIds
          .where((transactionId) => !pros.vouts.records
              .map((e) => e.transactionId)
              .contains(transactionId))
          .toSet();

  /// we capture securities here. if it's one we've never seen,
  /// get it's metadata and save it in the securities proclaim.
  /// return value and security to be saved in vout.
  Future<Tuple3<int, Security, Asset?>> handleAssetData(
    Tx tx,
    TxVout vout,
    Chain chain,
    Net net,
  ) async {
    var symbol = vout.scriptPubKey.asset ?? 'RVN';
    var value = vout.valueSat;
    var security = pros.securities.primaryIndex
        .getOne(symbol, SecurityType.asset, chain, net);
    var asset = pros.assets.primaryIndex.getOne(symbol, chain, net);
    if (security == null ||
        asset == null ||
        vout.scriptPubKey.type == 'reissue_asset') {
      if (['transfer_asset', 'reissue_asset']
          .contains(vout.scriptPubKey.type)) {
        value = utils.amountToSat(vout.scriptPubKey.amount);
        //if we have no record of it in pros.securities...
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
          chain: chain,
          net: net,
        );
        security = Security(
          symbol: symbol,
          securityType: SecurityType.asset,
          chain: chain,
          net: net,
        );
        await pros.assets.save(asset);
        await pros.securities.save(security);
        streams.asset.added.add(asset);
      }
    }
    return Tuple3(value, security ?? pros.securities.RVN, asset);
  }

  Future<List<Tx>> grabTransactions(Iterable<String> transactionIds) async {
    busy = true;
    var txs = <Tx>[];
    try {
      txs = await services.client.api.getTransactions(transactionIds);
    } catch (e) {
      var futures = <Future<Tx>>[];
      for (var transactionId in transactionIds) {
        futures.add(services.client.api.getTransaction(transactionId));
      }
      txs = await Future.wait<Tx>(futures);
    }
    return txs;
  }

  Future<Tuple3<Set<Transaction>, Set<Vin>, Set<Vout>>> parseTx(Tx tx) async {
    var newVins = <Vin>{};
    var newVouts = <Vout>{};
    var newTxs = <Transaction>{};
    Chain? chain;
    Net? net;
    var safeChain = Chain.none;
    var safeNet = Net.main;
    for (var vout in tx.vout) {
      if (vout.scriptPubKey.type == 'nullassetdata') continue;

      /// if addresses had a chain...
      //chain ??= pros.addresses.byAddress
      //    .getOne(vout.scriptPubKey.addresses?[0])
      //    ?.chain;
      //net ??=
      //    pros.addresses.byAddress.getOne(vout.scriptPubKey.addresses?[0])?.net;
      safeChain = chain ?? pros.settings.chain;
      safeNet = net ?? pros.settings.net;
      var vs = await handleAssetData(tx, vout, safeChain, safeNet);
      newVouts.add(Vout(
        //chain: safeChain,
        //net: safeNet,
        transactionId: tx.txid,
        position: vout.n,
        type: vout.scriptPubKey.type,
        lockingScript: vs.item3 != null ? vout.scriptPubKey.hex : null,
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
        //chain: safeChain,
        //net: safeNet,
        id: tx.txid,
        height: tx.height,
        confirmed: (tx.confirmations ?? 0) > 0,
        time: tx.time,
      ));
    }
    for (var vin in tx.vin) {
      if (vin.txid != null && vin.vout != null) {
        newVins.add(Vin(
          //chain: safeChain,
          //net: safeNet,
          transactionId: tx.txid,
          voutTransactionId: vin.txid!,
          voutPosition: vin.vout!,
        ));
      } else if (vin.coinbase != null && vin.sequence != null) {
        newVins.add(Vin(
          //chain: safeChain,
          //net: safeNet,
          transactionId: tx.txid,
          voutTransactionId: vin.coinbase!,
          voutPosition: vin.sequence!,
          isCoinbase: true,
        ));
      }
    }
    return Tuple3(newTxs, newVins, newVouts);
  }

  Future<void>? getTransactions(
    Iterable<String> transactionIds, {
    bool saveVin = true,
    bool saveVout = true,
  }) async {
    if (transactionIds.isEmpty) {
      return;
    }
    busy = true;
    var txs = <Tx>[];
    try {
      /// kinda a hack https://github.com/moontreeapp/moontree/issues/444#issuecomment-1101667621
      if (!saveVin) {
        /// for a wallet with any serious amount of transactions getTransactions
        /// will probably error in the event we're getting dangling transactions
        /// (saveVin == false) so in that case go straight to catch clause:
        throw Exception();
      }
      //print('getting transactionIds $transactionIds');
      txs = await services.client.api.getTransactions(transactionIds);
    } catch (e) {
      var futures = <Future<Tx>>[];
      for (var transactionId in transactionIds) {
        futures.add(services.client.api.getTransaction(transactionId));
      }
      txs = await Future.wait<Tx>(futures);
    }
    await saveTransactions(
      txs,
      saveVin: saveVin,
      saveVout: saveVout,
    );
    busy = false;
  }

  Future<void>? getTransaction(
    String transactionId, {
    bool saveVin = true,
  }) async =>
      await saveTransaction(
          await services.client.api.getTransaction(transactionId),
          saveVin: saveVin);

  /// when an address status change: make our historic tx data match blockchain
  Future<void> saveTransactions(
    List<Tx> txs, {
    bool saveVin = true,
    bool saveVout = true,
  }) async {
    var futures = [
      for (var tx in txs)
        saveTransaction(
          tx,
          saveVin: saveVin,
          saveVout: saveVout,
          justReturn: true,
        )
    ];
    await saveThese(
      await Future.wait<Tuple3<Set<Transaction>, Set<Vin>, Set<Vout>>>(futures),
    );
  }

  Future<void> saveThese(
    List<Tuple3<Set<Transaction>, Set<Vin>, Set<Vout>>> threes,
  ) async {
    final transactions = <Transaction>{};
    final vins = <Vin>{};
    final vouts = <Vout>{};
    for (var three in threes) {
      transactions.addAll(three.item1);
      vins.addAll(three.item2);
      vouts.addAll(three.item3);
    }
    await pros.transactions.saveAll(transactions);
    await pros.vins.saveAll(vins);
    await pros.vouts.saveAll(vouts);
  }

  Future<Tuple3<Set<Transaction>, Set<Vin>, Set<Vout>>> saveTransaction(
    Tx tx, {
    bool saveVin = true,
    bool saveVout = true,
    bool justReturn = false,
  }) async {
    var newVins = <Vin>{};
    var newVouts = <Vout>{};
    var newTxs = <Transaction>{};
    Chain? chain;
    Net? net;
    var safeChain = Chain.none;
    var safeNet = Net.main;
    for (var vout in tx.vout) {
      if (vout.scriptPubKey.type == 'nullassetdata') continue;

      /// if addresses had a chain...
      //chain ??= pros.addresses.byAddress
      //    .getOne(vout.scriptPubKey.addresses?[0])
      //    ?.chain;
      //net ??=
      //    pros.addresses.byAddress.getOne(vout.scriptPubKey.addresses?[0])?.net;
      safeChain = chain ?? pros.settings.chain;
      safeNet = net ?? pros.settings.net;
      var vs = await handleAssetData(tx, vout, safeChain, safeNet);
      if (saveVout) {
        newVouts.add(Vout(
          //chain: safeChain,
          //net: safeNet,
          transactionId: tx.txid,
          position: vout.n,
          type: vout.scriptPubKey.type,
          lockingScript: vs.item3 != null ? vout.scriptPubKey.hex : null,
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
      }
      newTxs.add(Transaction(
        //chain: safeChain,
        //net: safeNet,
        id: tx.txid,
        height: tx.height,
        confirmed: (tx.confirmations ?? 0) > 0,
        time: tx.time,
      ));
    }
    if (saveVin) {
      for (var vin in tx.vin) {
        if (vin.txid != null && vin.vout != null) {
          newVins.add(Vin(
            //chain: safeChain,
            //net: safeNet,
            transactionId: tx.txid,
            voutTransactionId: vin.txid!,
            voutPosition: vin.vout!,
          ));
        } else if (vin.coinbase != null && vin.sequence != null) {
          newVins.add(Vin(
            //chain: safeChain,
            //net: safeNet,
            transactionId: tx.txid,
            voutTransactionId: vin.coinbase!,
            voutPosition: vin.sequence!,
            isCoinbase: true,
          ));
        }
      }
    }
    if (justReturn) {
      return Tuple3(newTxs, newVins, newVouts);
    } else {
      await pros.transactions.saveAll(newTxs);
      await pros.vins.saveAll(newVins);
      await pros.vouts.saveAll(newVouts);
    }
    return Tuple3({}, {}, {});
  }
}
