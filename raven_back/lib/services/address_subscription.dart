import 'dart:async';

import 'package:quiver/iterables.dart';
//import 'package:raven/models/balance.dart';
import 'package:raven/reservoirs/address.dart';
import 'package:raven/reservoirs/history.dart';
import 'package:raven/reservoirs/wallet.dart';
import 'package:raven/services/address_derivation.dart'
    show AddressDerivationService;
import 'package:raven/services/service.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

import '../utils/buffer_count_window.dart';
import '../models.dart';

class ScripthashHistoryRow {
  final Address address;
  final List<ScripthashHistory> history;
  final List<ScripthashUnspent> unspent;
  final List<ScripthashUnspent> assetUnspent;

  ScripthashHistoryRow(
      this.address, this.history, this.unspent, this.assetUnspent);
}

class ScripthashHistoriesData {
  final List<Address> addresses;
  final List<List<ScripthashHistory>> histories;
  final List<List<ScripthashUnspent>> unspents;
  final List<List<ScripthashUnspent>> assetUnspents;

  ScripthashHistoriesData(
      this.addresses, this.histories, this.unspents, this.assetUnspents);

  Iterable<ScripthashHistoryRow> get zipped =>
      zip([addresses, histories, unspents]).map((e) => ScripthashHistoryRow(
          e[0] as Address,
          e[1] as List<ScripthashHistory>,
          e[2] as List<ScripthashUnspent>,
          e[3] as List<ScripthashUnspent>));
}

/// balance isn't necessary -
/// histries with height of 0 are in mempool and "unconfirmed"
//class ScripthashBalanceRow {
//  final Address address;
//  final Balances balances;
//
//  ScripthashBalanceRow(this.address, this.balances);
//}
//
//class ScripthashBalancesData {
//  final List<Address> addresses;
//  final List<ScripthashBalance> balances;
//  final List<ScripthashAssetBalances> assetBalances;
//
//  ScripthashBalancesData(this.addresses, this.balances, this.assetBalances);
//
//  Iterable<ScripthashBalanceRow> get zipped =>
//      zip([addresses, balances, conformedAssetBalances()])
//          .map((e) => ScripthashBalanceRow(
//              e[0] as Address,
//              Balances(balances: {
//                ...e[2] as Map<String, Balance>,
//                ...{'R': e[1] as Balance}
//              })));
//
//  List<Balances> conformedAssetBalances() {
//    var assetBalancesConformed;
//    for (var assetsBalance in assetBalances) {
//      assetBalancesConformed.add(toAssetMap(assetsBalance));
//    }
//    return assetBalancesConformed;
//  }
//
//  Balances toAssetMap(ScripthashAssetBalances balances) {
//    var tickers = {
//      ...balances.confirmed.keys.toList(),
//      ...balances.unconfirmed.keys.toList()
//    };
//    //var ret;
//    //for (var ticker in tickers) {
//    //  ret[ticker] = Balance(
//    //      confirmed: balances.confirmed[ticker] ?? 0,
//    //      unconfirmed: balances.unconfirmed[ticker] ?? 0);
//    //}
//    return Balances(balances: {
//      for (var ticker in tickers)
//        ticker: Balance(
//            confirmed: balances.confirmed[ticker] ?? 0,
//            unconfirmed: balances.unconfirmed[ticker] ?? 0)
//    });
//  }
//}

class AddressSubscriptionService extends Service {
  WalletReservoir wallets;
  AddressReservoir addresses;
  HistoryReservoir histories;
  RavenElectrumClient client;
  AddressDerivationService addressDerivationService;
  Map<String, StreamSubscription> subscriptionHandles = {};
  List<StreamSubscription> listeners = [];

  StreamController<Address> addressesNeedingUpdate = StreamController();

  AddressSubscriptionService(this.wallets, this.addresses, this.histories,
      this.client, this.addressDerivationService)
      : super();

  @override
  void init() {
    subscribeToExistingAddresses();

    listeners.add(addressesNeedingUpdate.stream
        .bufferCountTimeout(10, Duration(milliseconds: 50))
        .listen((changedAddresses) async {
      saveScripthashHistoryData(
          await getScripthashHistoriesData(changedAddresses));
      //saveScripthashBalanceData(
      //    await getScripthashBalancesData(changedAddresses));
      addressDerivationService.maybeDeriveNewAddresses(changedAddresses);
    }));

    listeners.add(addresses.changes.listen((change) {
      change.when(added: (added) {
        Address address = added.data;
        addressNeedsUpdating(address);
        subscribe(address);
      }, updated: (updated) {
        // pass - see initialize.dart
      }, removed: (removed) {
        unsubscribe(removed.id as String);
      });
    }));
  }

  @override
  void deinit() {
    for (var listener in listeners) {
      listener.cancel();
    }
  }

  void addressNeedsUpdating(Address address) {
    addressesNeedingUpdate.sink.add(address);
  }

  void subscribe(Address address) {
    var stream = client.subscribeScripthash(address.scripthash);
    subscriptionHandles[address.scripthash] = stream.listen((status) {
      addressNeedsUpdating(address);
    });
  }

  void unsubscribe(String scripthash) {
    subscriptionHandles[scripthash]!.cancel();
  }

  void subscribeToExistingAddresses() {
    for (var address in addresses) {
      subscribe(address);
    }
  }

  Future<ScripthashHistoriesData> getScripthashHistoriesData(
      List<Address> changedAddresses) async {
    var scripthashes =
        changedAddresses.map((address) => address.scripthash).toList();
    // ignore: omit_local_variable_types
    List<List<ScripthashHistory>> histories =
        await client.getHistories(scripthashes);
    // ignore: omit_local_variable_types
    List<List<ScripthashUnspent>> unspents =
        await client.getUnspents(scripthashes);
    // ignore: omit_local_variable_types
    List<List<ScripthashUnspent>> assetUnspents =
        await client.getAssetUnspents(scripthashes);
    return ScripthashHistoriesData(
        changedAddresses, histories, unspents, assetUnspents);
  }

  //Future<ScripthashBalancesData> getScripthashBalancesData(
  //    List<Address> changedAddresses) async {
  //  var scripthashes =
  //      changedAddresses.map((address) => address.scripthash).toList();
  //  // ignore: omit_local_variable_types
  //  List<ScripthashBalance> balances = await client.getBalances(scripthashes);
  //  // ignore: omit_local_variable_types
  //  List<ScripthashAssetBalances> assetBalances =
  //      await client.getAssetBalances(scripthashes);
  //  return ScripthashBalancesData(changedAddresses, balances, assetBalances);
  //}

  //void saveScripthashBalanceData(ScripthashBalancesData data) async {
  //  data.zipped.forEach((row) {
  //    var address = row.address;
  //    address.balances = row.balances;
  //    addresses.save(address);
  //  });
  //}

  void saveScripthashHistoryData(ScripthashHistoriesData data) async {
    data.zipped.forEach((row) {
      // var address = row.address;
      // addresses.save(address);
      histories.saveAll(combineHistoryAndUnspents(row));
    });
  }

  List<History> combineHistoryAndUnspents(ScripthashHistoryRow row) {
    var newHistories = <History>[];
    for (var history in row.history) {
      newHistories.add(History.fromScripthashHistory(row.address.accountId,
          row.address.walletId, row.address.scripthash, history));
    }
    for (var unspent in row.unspent) {
      newHistories.add(History.fromScripthashUnspent(row.address.accountId,
          row.address.walletId, row.address.scripthash, unspent));
    }
    for (var unspent in row.assetUnspent) {
      newHistories.add(History.fromScripthashUnspent(row.address.accountId,
          row.address.walletId, row.address.scripthash, unspent));
    }
    return newHistories;
  }
}
