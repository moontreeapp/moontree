import 'dart:async';

import 'package:quiver/iterables.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

import 'package:raven/raven.dart';

class ScripthashHistoryRow {
  final String scripthash;
  final List<ScripthashHistory> history;
  final List<ScripthashUnspent> unspent;
  final List<ScripthashUnspent> assetUnspent;

  ScripthashHistoryRow(
      this.scripthash, this.history, this.unspent, this.assetUnspent);
}

class ScripthashHistoriesData {
  final List<String> scripthashes;
  final List<List<ScripthashHistory>> histories;
  final List<List<ScripthashUnspent>> unspents;
  final List<List<ScripthashUnspent>> assetUnspents;

  ScripthashHistoriesData(
      this.scripthashes, this.histories, this.unspents, this.assetUnspents);

  Iterable<ScripthashHistoryRow> get zipped =>
      zip([scripthashes, histories, unspents, assetUnspents]).map((e) =>
          ScripthashHistoryRow(
              e[0] as String,
              e[1] as List<ScripthashHistory>,
              e[2] as List<ScripthashUnspent>,
              e[3] as List<ScripthashUnspent>));
}

class AddressService {
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
        scripthashes, histories, unspents, assetUnspents);
  }

  Future saveScripthashHistoryData(ScripthashHistoriesData data) async {
    for (var row in data.zipped) {
      await histories.saveAll(combineHistoryAndUnspents(row));
    }
  }

  List<History> combineHistoryAndUnspents(ScripthashHistoryRow row) {
    var newHistories = <History>[];
    for (var history in row.history) {
      newHistories.add(History.fromScripthashHistory(row.scripthash, history));
    }
    for (var unspent in row.unspent) {
      newHistories.add(History.fromScripthashUnspent(row.scripthash, unspent));
    }
    for (var unspent in row.assetUnspent) {
      newHistories.add(History.fromScripthashUnspent(row.scripthash, unspent));
    }
    return newHistories;
  }
}
