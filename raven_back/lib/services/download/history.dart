import 'dart:async';
import 'package:raven_back/utilities/lock.dart';
import 'package:tuple/tuple.dart';
import 'package:raven_electrum/raven_electrum.dart';
import 'package:raven_back/raven_back.dart';

class HistoryService {
  final Set<String> _downloadQueried = {};
  final _downloadQueriedLock = ReaderWriterLock();
  int _downloaded = 0;
  int _new_length = 0;

  /// called during import process, leader registry counts handled separately.
  Future<List<List<String>>> getHistories(List<Address> addresses) async {
    try {
      var listOfLists = await services.client.api.getHistories(addresses);
      return [
        for (var x in listOfLists) x.map((history) => history.txHash).toList()
      ];
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
        return txIds;
      } catch (e) {
        return [for (var _ in addresses) []];
      }
    }
  }

  /// called during address subscription
  Future<List<String>> getHistory(
    Address address, {
    bool updateLeader = false,
  }) async {
    try {
      final t = (await services.client.api.getHistory(address))
          .map((history) => history.txHash)
          .toList();
      if (updateLeader && address.wallet is LeaderWallet) {
        if (t.isEmpty) {
          services.wallet.leader
              .updateCache(address, address.wallet as LeaderWallet);
        } else {
          services.wallet.leader
              .updateCounts(address, address.wallet as LeaderWallet);
        }
      }
      return t;
    } catch (e) {
      return [];
    }
  }

  Future getAndSaveMempoolTransactions() async {
    await saveTransactions(
      [
        for (var transactionId in res.transactions.mempool.map((t) => t.id))
          await services.client.api.getTransaction(transactionId)
      ],
    );
  }

  Future allDoneProcess() async {
    //print('TRANSACTIONS DOWNLOADED');
    await saveDanglingTransactions();
    //print('ALL DONE!');
    //services.download.asset.allAdminsSubs(); // why?
    // remove vouts pointing to addresses we don't own?
  }

  /// don't need this for creating UTXO set anymore but...
  /// still need this for getting correct balances of some transactions...
  /// one more step - get all vins that have no corresponding vout (in the db)
  /// and get the vouts for them
  Future saveDanglingTransactions() async {
    var txs =
        (res.vins.danglingVins.map((vin) => vin.voutTransactionId).toSet());
    await getTransactions(txs, saveVin: false, saveVout: true);
  }

  /// we capture securities here. if it's one we've never seen,
  /// get it's metadata and save it in the securities reservoir.
  /// return value and security to be saved in vout.
  Future<Tuple3<int, Security, Asset?>> handleAssetData(
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

  Iterable<String> _filterOut(Iterable<String> transactionIds) => transactionIds
      .where((transactionId) =>
          !res.transactions.data.map((e) => e.id).contains(transactionId))
      .toSet();

  Future<void>? getTransactions(
    Iterable<String> transactionIds, {
    bool saveVin = true,
    bool saveVout = true,
  }) async {
    transactionIds = _filterOut(transactionIds);
    if (transactionIds.isEmpty) {
      return;
    }
    await _downloadQueriedLock.write(() {
      _downloadQueried.addAll(transactionIds);
      _new_length = _downloadQueried.length;
    });
    var txs = <Tx>[];
    try {
      /// kinda a hack https://github.com/moontreeapp/moontree/issues/444#issuecomment-1101667621
      if (!saveVin) {
        /// for a wallet with any serious amount of transactions getTransactions
        /// will probably error in the event we're getting dangling transactions
        /// (saveVin == false) so in that case go straight to catch clause:
        throw Exception();
      }
      txs = await services.client.api.getTransactions(transactionIds);
    } catch (e) {
      var futures = <Future<Tx>>[];
      for (var transactionId in transactionIds) {
        futures.add(services.client.api.getTransaction(transactionId));
      }
      txs = await Future.wait<Tx>(futures);
    }
    _downloaded += transactionIds.length;
    await saveTransactions(
      txs,
      saveVin: saveVin,
      saveVout: saveVout,
    );
  }

  Future<void>? getTransaction(
    String transactionId, {
    bool saveVin = true,
  }) async {
    if (_filterOut([transactionId]).isNotEmpty) {
      await _downloadQueriedLock.write(() {
        _downloadQueried.add(transactionId);
        _new_length = _downloadQueried.length;
      });
      await saveTransaction(
          await services.client.api.getTransaction(transactionId),
          saveVin: saveVin);
      _downloaded += 1;
    } else {
      print('skipping: $transactionId');
    }
  }

  /// when an address status change: make our historic tx data match blockchain
  Future saveTransactions(
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
    var threes = await Future.wait<List<Set>>(futures);
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
      }
    }
  }

  Future<List<Set>> saveTransaction(
    Tx tx, {
    bool saveVin = true,
    bool saveVout = true,
    bool justReturn = false,
  }) async {
    var newVins = <Vin>{};
    var newVouts = <Vout>{};
    var newTxs = <Transaction>{};

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
      var vs = await handleAssetData(tx, vout);
      if (saveVout) {
        newVouts.add(Vout(
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

  Future<void> clearDownloadState() async {
    await _downloadQueriedLock.write(() {
      _downloadQueried.clear();
    });
    _downloaded = 0;
    _new_length = 0;
  }

  bool get downloads_complete => _downloaded == _new_length;
}
