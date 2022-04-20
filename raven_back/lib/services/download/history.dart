import 'dart:async';
import 'package:raven_back/utilities/lock.dart';
import 'package:tuple/tuple.dart';
import 'package:raven_electrum/raven_electrum.dart';
import 'package:raven_back/streams/wallet.dart';
import 'package:raven_back/raven_back.dart';

class HistoryService {
  // These are all modified from a bunch of places so it seems smart to have
  // A lock on them, unsure if nessissary
  final Set<String> _downloadQueried = {};
  final _downloadQueriedLock = ReaderWriterLock();
  int _downloaded = 0;
  int _new_length = 0;
  final Set<Address> _addresses = {};
  final _addressesLock = ReaderWriterLock();
  final Map<String, Set<Set<String>>> _txsListsByWalletExposureKeys = {};
  final _txsListsByWalletExposureKeysLock = ReaderWriterLock();

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
    var histories = await client.getHistory(address.id);
    await _addressesLock.enterWrite();
    _addresses.add(address);
    await _addressesLock.exitWrite();
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
    await _remember(address, histories.map((history) => history.txHash));
    await _addressesLock.enterRead();
    final addr_length = _addresses.length;
    await _addressesLock.exitRead();
    if (addr_length ==
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
      await services.balance.recalculateAllBalances();
      print('getting Transactions');

      var txsToDownload = <String>[];
      await _txsListsByWalletExposureKeysLock.enterRead();
      for (var key in _txsListsByWalletExposureKeys.keys) {
        for (var txsList in _txsListsByWalletExposureKeys[key]!) {
          txsToDownload.addAll(txsList);
        }
      }
      await _txsListsByWalletExposureKeysLock.exitRead();

      // Get transactions 10 at a time
      // Arbitrary number
      while (txsToDownload.isNotEmpty) {
        final chunk_size =
            txsToDownload.length < 10 ? txsToDownload.length : 10;
        await getTransactions(txsToDownload.sublist(0, chunk_size));
        txsToDownload = txsToDownload.sublist(chunk_size);
      }

      // don't clear because if we get updates we want to pull tx
      //addresses.clear();
      return await produceAddressOrBalance();
    }
    return null;
  }

  String produceKey(Address address) =>
      address.walletId + address.exposure.enumString;

  Future<void> _remember(Address address, Iterable<String> txs) async {
    var key = produceKey(address);

    await _txsListsByWalletExposureKeysLock.enterWrite();
    if (!_txsListsByWalletExposureKeys.containsKey(key)) {
      _txsListsByWalletExposureKeys[key] = <Set<String>>{};
    }
    _txsListsByWalletExposureKeys[key]!.add(txs.toSet());
    await _txsListsByWalletExposureKeysLock.exitWrite();
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
      print('TRANSACTIONS DOWNLOADED');
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
    //await services.balance.recalculateAllBalancesFromTransactions();
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

  Future<void>? getTransaction(
    String transactionId, {
    bool saveVin = true,
  }) async {
    var client = streams.client.client.value;
    if (client == null) {
      return;
    }
    // not already downloaded?
    await _downloadQueriedLock.enterRead();
    final downloadNewTx = !_downloadQueried.contains(transactionId);
    await _downloadQueriedLock.exitRead();
    if (downloadNewTx) {
      await _downloadQueriedLock.enterWrite();
      _downloadQueried.add(transactionId);
      _new_length = _downloadQueried.length;
      await _downloadQueriedLock.exitWrite();

      final tx = await client.getTransaction(transactionId);
      await saveTransaction(tx, client, saveVin: saveVin);
      _downloaded += 1;
    } else {
      print('skipping: $transactionId');
    }
  }

  Future<void>? getTransactions(
    Iterable<String> transactionIds, {
    bool saveVin = true,
  }) async {
    var client = streams.client.client.value;
    if (client == null) {
      return null;
    }
    // filter out already downloaded
    transactionIds = transactionIds
        .where((transactionId) => !_downloadQueried.contains(transactionId))
        .toSet();
    await _downloadQueriedLock.enterWrite();
    _downloadQueried.addAll(transactionIds);
    _new_length = _downloadQueried.length;
    await _downloadQueriedLock.exitWrite();
    var txs = <Tx>[];
    try {
      /// kinda a hack https://github.com/moontreeapp/moontree/issues/444#issuecomment-1101667621
      if (!saveVin) {
        /// for a wallet with any serious amount of transactions getTransactions
        /// will probably error in the event we're getting dangling transactions
        /// (saveVin == false) so in that case go straight to catch clause:
        throw Exception();
      }
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
    _downloaded += transactionIds.length;
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

  Future<void> addAddressToSkipHistory(Address address) async {
    await _addressesLock.enterWrite();
    _addresses.add(address);
    await _addressesLock.exitWrite();
  }

  Future<void> clearDownloadState() async {
    await _downloadQueriedLock.enterWrite();
    _downloadQueried.clear();
    _downloaded = 0;
    _new_length = 0;
    await _downloadQueriedLock.exitWrite();
  }

  bool get downloads_complete => _downloaded == _new_length;
}
