import 'dart:async';
import 'package:tuple/tuple.dart';
import 'package:raven_electrum/raven_electrum.dart';
import 'package:raven_back/streams/wallet.dart';
import 'package:raven_back/raven_back.dart';

class HistoryService {
  Set<String> downloaded = {};
  Set<Address> addresses = {};
  Map<String, List<List<String>>> txsListsByWalletExposureKeys = {};

  Future<bool?> getHistories(Address address) async {
    void updateCounts(LeaderWallet leader) {
      leader.removeUnused(address.hdIndex, address.exposure);
      services.wallet.leader
          .updateIndexOf(leader, address.exposure, used: address.hdIndex);
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
    addresses.add(address);
    if (address.wallet is LeaderWallet) {
      if (histories.isNotEmpty) {
        updateCounts(address.wallet as LeaderWallet);
      } else {
        updateCache(address.wallet as LeaderWallet);
      }
      if (address.hdIndex >=
          services.wallet.leader
              .getIndexOf(address.wallet as LeaderWallet, address.exposure)
              .saved) {
        streams.wallet.deriveAddress.add(DeriveLeaderAddress(
            leader: address.wallet as LeaderWallet,
            exposure: address.exposure));
      }
    }
    remember(address, histories.map((history) => history.txHash));
    if (addresses.length ==
            services.wallet.leader.indexRegistry.values
                .map((e) => e.saved)
                .sum() /*plus single wallets*2 */
        &&
        () {
          for (var leader in res.wallets.leaders) {
            for (var exposure in [
              NodeExposure.Internal,
              NodeExposure.External
            ]) {
              if (!services.wallet.leader.gapSatisfied(leader, exposure)) {
                return false;
              }
            }
          }
          return true;
        }()) {
      await services.balance.recalculateAllBalancesByUnspents();
      print('getting Transactions');
      for (var key in txsListsByWalletExposureKeys.keys) {
        for (var txsList in txsListsByWalletExposureKeys[key]!) {
          await getTransactions(txsList);
        }
      }
      // shouldn't need this, we can probably clean up the memory.
      //txsListsByWalletExposureKeys[produceKey(address)] = <List<String>>[];
      // don't clear because if we get updates we want to pull tx
      //addresses.clear();
      return await produceAddressOrBalance();
    }
    return null;
  }

  String produceKey(Address address) =>
      address.walletId + address.exposure.enumString;

  void remember(Address address, Iterable<String> txs) {
    var key = produceKey(address);
    txsListsByWalletExposureKeys.containsKey(key)
        ? txsListsByWalletExposureKeys[key]!.add(txs.toList())
        : txsListsByWalletExposureKeys[key] = <List<String>>[];
  }

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
        }
      }
    }
    if (allDone) {
      await allDoneProcess(client);
    }
    return allDone;
  }

  Future allDoneProcess([RavenElectrumClient? client]) async {
    client = client ?? streams.client.client.value;
    if (client == null) {
      return false;
    }
    print('ALL DONE!');
    await saveDanglingTransactions(client);
    //await services.balance.recalculateAllBalances();
    //services.download.asset.allAdminsSubs(); // why?
    // remove vouts pointing to addresses we don't own?
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
    //await services.balance.recalculateAllBalances();
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

  /// don't need this for creating UTXO set anymore but...
  /// still need this for getting correct balances of some transactions...
  /// one more step - get all vins that have no corresponding vout (in the db)
  /// and get the vouts for them
  Future saveDanglingTransactions(RavenElectrumClient client) async {
    var txs =
        (res.vins.danglingVins.map((vin) => vin.voutTransactionId).toSet());
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
      return client.getTransaction(transactionId).then((tx) async {
        await saveTransaction(tx, client, saveVin: saveVin);
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
    transactionIds = transactionIds
        .where((transactionId) => !downloaded.contains(transactionId))
        .toSet();
    downloaded.addAll(transactionIds);
    var txs = <Tx>[];
    try {
      txs = await client.getTransactions(transactionIds);
    } catch (e) {
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
      var vs = await handleAssetData(client, tx, vout);
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
