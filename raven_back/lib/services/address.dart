import 'dart:async';

import 'package:quiver/iterables.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

import 'package:raven/raven.dart';

class ScripthashHistoryRow {
  final String addressId;
  final List<ScripthashHistory> history;
  final List<ScripthashUnspent> unspent;
  final List<ScripthashUnspent> assetUnspent;

  ScripthashHistoryRow(
      this.addressId, this.history, this.unspent, this.assetUnspent);
}

class ScripthashHistoriesData {
  final List<String> addressIds;
  final List<List<ScripthashHistory>> histories;
  final List<List<ScripthashUnspent>> unspents;
  final List<List<ScripthashUnspent>> assetUnspents;

  ScripthashHistoriesData(
      this.addressIds, this.histories, this.unspents, this.assetUnspents);

  Iterable<ScripthashHistoryRow> get zipped =>
      zip([addressIds, histories, unspents, assetUnspents]).map((e) =>
          ScripthashHistoryRow(
              e[0] as String,
              e[1] as List<ScripthashHistory>,
              e[2] as List<ScripthashUnspent>,
              e[3] as List<ScripthashUnspent>));
}

class AddressService {
  /// when an address status change: make our historic tx data match blockchain
  Future<ScripthashHistoriesData> getScripthashHistoriesData(
    List<Address> changedAddresses,
    RavenElectrumClient client,
  ) async {
    var addressIds =
        changedAddresses.map((address) => address.addressId).toList();
    // ignore: omit_local_variable_types
    List<List<ScripthashHistory>> histories =
        await client.getHistories(addressIds);

    // get all transactions from transactionids in histories,

    // calculate unspents and save vout composite id (tx and position) in another res.

    // ignore: omit_local_variable_types
    List<List<ScripthashUnspent>> unspents =
        await client.getUnspents(addressIds);
    if ([for (var ca in changedAddresses) ca.address]
        .contains('mpVNTrVvNGK6YfSoLsiMMCrpLoX2Vt6Tkm')) {
      print('ADDRESSSERVICE:');
      print(changedAddresses);
      print(unspents);
    }
    // ignore: omit_local_variable_types
    List<List<ScripthashUnspent>> assetUnspents =
        await client.getAssetUnspents(addressIds);
    return ScripthashHistoriesData(
        addressIds,
        await appendMemosHistory(client, histories),
        await appendMemosUnspent(client, unspents),
        await appendMemosUnspent(client, assetUnspents));
  }

  Future<List<List<ScripthashHistory>>> appendMemosHistory(
    RavenElectrumClient client,
    List<List<ScripthashHistory>> histories,
  ) async {
    var outter = <List<ScripthashHistory>>[];
    for (var historiesByScripthash in histories) {
      var inner = <ScripthashHistory>[];
      for (var history in historiesByScripthash) {
        history.memo = await client.getMemo(history.txHash);
        //print('history.memo');
        //print(history.memo);
        //print('await client.getMemo(history.txHash);');
        //print(await client.getMemo(history.txHash));
        inner.add(history);
      }
      outter.add(inner);
    }
    return outter;
  }

  Future<List<List<ScripthashUnspent>>> appendMemosUnspent(
    RavenElectrumClient client,
    List<List<ScripthashUnspent>> unspents,
  ) async {
    var outter = <List<ScripthashUnspent>>[];
    for (var unspentsByScripthash in unspents) {
      var inner = <ScripthashUnspent>[];
      for (var unspent in unspentsByScripthash) {
        unspent.memo = await client.getMemo(unspent.txHash);
        //print('unspent.memo');
        //print(unspent.memo);
        inner.add(unspent);
      }
      outter.add(inner);
    }
    return outter;
  }

  Future saveScripthashHistoryData(ScripthashHistoriesData data) async {
    for (var row in data.zipped) {
      await histories.saveAll(combineHistoryAndUnspents(row));
      print('HISTORIES RIGHT AFTER SAVE:');
      for (var item in histories.data) {
        print(item);
      }
    }
  }

  List<History> combineHistoryAndUnspents(ScripthashHistoryRow row) {
    var newHistories = <History>[];
    for (var history in row.history) {
      if (row.addressId ==
          '204d127aea0dfa26a53eeb9fa89220aee54440f5dcb4f015d3b57861d3d1d7ca') {
        print('SAVING:history:$history');
      }
      newHistories.add(History.fromScripthashHistory(row.addressId, history));
    }
    for (var unspent in row.unspent) {
      if (row.addressId ==
          '204d127aea0dfa26a53eeb9fa89220aee54440f5dcb4f015d3b57861d3d1d7ca') {
        print('SAVING:unspent:$unspent');
      }
      newHistories.add(History.fromScripthashUnspent(row.addressId, unspent));
    }
    for (var unspent in row.assetUnspent) {
      if (row.addressId ==
          '204d127aea0dfa26a53eeb9fa89220aee54440f5dcb4f015d3b57861d3d1d7ca') {
        print('SAVING:unspent:$unspent');
      }
      newHistories.add(History.fromScripthashUnspent(row.addressId, unspent));
    }
    return newHistories;
  }
}
