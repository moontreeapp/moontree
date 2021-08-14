import 'dart:async';
import 'package:quiver/iterables.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'package:raven/waiters/waiter.dart';
import 'package:raven/records.dart';
import 'package:raven/reservoirs.dart';

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

//class AddressSubscriptionWaiter extends Waiter {
//  late final BalanceReservoir balances;
//  late final HistoryReservoir histories;
//
//  AddressSubscriptionWaiter() : super() {
//    balances = ReservoirsSteward().balances;
//    histories = ReservoirsSteward().histories;
//  }

class AddressSubscriptionWaiter extends Waiter {
  late final BalanceReservoir balances;
  late final HistoryReservoir histories;

  AddressSubscriptionWaiter(this.balances, this.histories) : super();

  Future<ScripthashHistoriesData> getScripthashHistoriesData(
    List<Address> changedAddresses,
    RavenElectrumClient client,
  ) async {
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

  void saveScripthashHistoryData(ScripthashHistoriesData data) async {
    data.zipped.forEach((row) {
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
