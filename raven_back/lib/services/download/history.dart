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
  final Map<String, Set<Address>> _addressesByWalletId = {};
  final _addressesLock = ReaderWriterLock();
  final Map<Address, String?> _statusesToSave = {};
  final _statusesLock = ReaderWriterLock();
  final Map<String, Set<Set<String>>> _txsListsByWalletExposureKeys = {};
  final _txsListsByWalletExposureKeysLock = ReaderWriterLock();

  var _saveImmediately = false;

  List<Iterable<String>> unspentsTxsFetchFirst = [];

  Future<bool?> getHistories(Address address, String? status) async {
    var client = streams.client.client.value;
    if (client == null) {
      return false;
    }
    await _statusesLock.write(() => _statusesToSave[address] = status);
    var histories = await client.getHistory(address.id);
    await _addressesLock.write(() {
      if (!_addressesByWalletId.keys.contains(address.walletId)) {
        _addressesByWalletId[address.walletId] = <Address>{};
      }
      _addressesByWalletId[address.walletId]!.add(address);
    });

    var complete = false;

    if (address.wallet is LeaderWallet) {
      if (histories.isNotEmpty) {
        services.wallet.leader
            .updateCounts(address, address.wallet as LeaderWallet);
      } else {
        services.wallet.leader
            .updateCache(address, address.wallet as LeaderWallet);
      }
      if (address.hdIndex >=
          services.wallet.leader
              .getIndexOf(address.wallet as LeaderWallet, address.exposure)
              .saved) {
        /*
        print(
            'Checked address ${address.address} is >= saved address of that exposure');
        */
        streams.wallet.deriveAddress.add(DeriveLeaderAddress(
            leader: address.wallet as LeaderWallet,
            exposure: address.exposure));
      } else {
        // New address derivation unneeded; check if the histories gotten == wallet addresses
        // we derive last used + 20 =>
        // implies all addresses checked & and no more derivations needed => all done
        await _addressesLock.read(() {
          // We will not get the callback for the final address derivation
          // if actually deriving => -1
          if (_addressesByWalletId[address.walletId]!.length >=
              address.wallet!.addresses.length - 1) {
            complete = true;
            streams.wallet.walletSyncedCallback.add(address.walletId);
          }
        });
      }
    } else {
      // One address; all good
      streams.wallet.walletSyncedCallback.add(address.walletId);
      complete = true;
    }

    // Only remember stuff we haven't already downloaded
    await _remember(
        address,
        histories
            .map((history) => history.txHash)
            .where((txid) => !res.transactions.contains(txid)));
    final addr_length = await _addressesLock.read(() {
      return _addressesByWalletId.values.expand((element) => element).length;
    });

    /*
    print(
        'Gotten $addr_length vs have ${res.wallets.primaryIndex.getOne(res.settings.currentWalletId)!.addresses.length}');
    */

    final current =
        res.wallets.primaryIndex.getOne(res.settings.currentWalletId)!;
    if (_saveImmediately ||
        (addr_length ==
                services.wallet.leader.indexRegistry.values
                    .map((e) => e.saved)
                    .sum() /*plus single wallets*2 */ &&
            () {
              if (current is LeaderWallet) {
                for (var exposure in [
                  NodeExposure.Internal,
                  NodeExposure.External
                ]) {
                  if (!services.wallet.leader.gapSatisfied(current, exposure)) {
                    print('Exposure $exposure is not satisfied');
                    return false;
                  }
                }
              }
              return true;
            }())) {
      _saveImmediately = true;
      //print('getting Transactions');
      //streams.wallet.scripthashCallback.add(null); // make home listen to balances instead?
      //if (downloads_complete) {
      //  streams.client.busy.add(false);
      //}
      var txsToDownload = (await _txsListsByWalletExposureKeysLock.read(() {
        return _txsListsByWalletExposureKeys.values
            .expand((element) => element)
            .expand((element) => element);
      }))
          .toList();

      // Get unspents first
      // Unspents we don't have implies history we dont have implies this gets called
      while (unspentsTxsFetchFirst.isNotEmpty) {
        await getTransactions(unspentsTxsFetchFirst.removeAt(0));
      }

      // Get transactions 10 at a time
      // Arbitrary number
      while (txsToDownload.isNotEmpty) {
        final chunk_size =
            txsToDownload.length < 10 ? txsToDownload.length : 10;
        await getTransactions(txsToDownload.sublist(0, chunk_size));
        txsToDownload = txsToDownload.sublist(chunk_size);
      }

      final statuses = <Address, String?>{};
      await _statusesLock.write(() {
        for (final address in _statusesToSave.keys) {
          statuses[address] = _statusesToSave[address];
        }
        _statusesToSave.clear();
      });

      for (final address in statuses.keys) {
        await res.statuses.save(Status(
            linkId: address.id,
            statusType: StatusType.address,
            status: statuses[address]));
      }

      // don't clear because if we get updates we want to pull tx
      //addresses.clear();
      final retVal = await _produceAddressOrBalance();
      if (complete) {
        // Ensure we get dangling ONLY once we've downloaded all normal transactions
        // (i.e. wallet completely synced)
        // Removes weird edge cases when we send to ourselves with regards to saving vins
        await allDoneProcess(client);
        print('TRANSACTIONS DOWNLOADED');
      }
      return retVal;
    }
    return null;
  }

  String produceKey(Address address) =>
      address.walletId + address.exposure.enumString;

  Future<void> _remember(Address address, Iterable<String> txs) async {
    var key = produceKey(address);
    await _txsListsByWalletExposureKeysLock.write(() {
      if (!_txsListsByWalletExposureKeys.containsKey(key)) {
        _txsListsByWalletExposureKeys[key] = <Set<String>>{};
      }
      _txsListsByWalletExposureKeys[key]!.add(txs.toSet());
    });
  }

  Future<bool> _produceAddressOrBalance() async {
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
  }

  /// when an address status change: make our historic tx data match blockchain
  Future saveTransactions(
    List<Tx> txs,
    RavenElectrumClient client, {
    bool saveVin = true,
  }) async {
    var futures = [
      for (var tx in txs)
        saveTransaction(tx, client, saveVin: saveVin, justReturn: false)
    ];
    await Future.wait<List<Set>>(futures);
    // Saving is done in the method??

    /*
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
    */
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
    final downloadNewTx = await _downloadQueriedLock.read(() {
      !_downloadQueried.contains(transactionId);
    });
    if (downloadNewTx) {
      await _downloadQueriedLock.write(() {
        _downloadQueried.add(transactionId);
        _new_length = _downloadQueried.length;
      });
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
    await _addressesLock.write(() {
      if (!_addressesByWalletId.containsKey(address.walletId)) {
        _addressesByWalletId[address.walletId] = <Address>{};
      }
    });
    if (!_saveImmediately) {
      final wallet = res.wallets.primaryIndex
          .getOne(res.settings.currentWalletId)!
          .addresses;
      final addressesNeeded = wallet is LeaderWallet
          ? (wallet as LeaderWallet).addresses.length
          : 1;
      await _addressesLock.write(() {
        _addressesByWalletId[address.walletId]!.add(address);
        if (_addressesByWalletId.values.expand((element) => element).length >=
            addressesNeeded) _saveImmediately = true;
      });
    } else {
      await _addressesLock.write(() {
        _addressesByWalletId[address.walletId]!.add(address);
      });
    }
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
