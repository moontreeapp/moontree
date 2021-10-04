import 'dart:async';

import 'package:quiver/iterables.dart';
import 'package:raven/utils/parse.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

import 'package:raven/raven.dart';

class ScripthashHistoryRow {
  final String scripthash;
  final List<ScripthashHistory> history;
  final List<ScripthashUnspent> unspent;
  final List<ScripthashUnspent> assetUnspent;
  final List<String> memo;

  ScripthashHistoryRow(this.scripthash, this.history, this.unspent,
      this.assetUnspent, this.memo);
}

class ScripthashHistoriesData {
  final List<String> scripthashes;
  final List<List<ScripthashHistory>> histories;
  final List<List<ScripthashUnspent>> unspents;
  final List<List<ScripthashUnspent>> assetUnspents;
  final List<List<String>> memos;

  ScripthashHistoriesData(this.scripthashes, this.histories, this.unspents,
      this.assetUnspents, this.memos);

  Iterable<ScripthashHistoryRow> get zipped =>
      zip([scripthashes, histories, unspents, assetUnspents, memos]).map((e) =>
          ScripthashHistoryRow(
              e[0] as String,
              e[1] as List<ScripthashHistory>,
              e[2] as List<ScripthashUnspent>,
              e[3] as List<ScripthashUnspent>,
              e[4] as List<String>));
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

    /// if we want to get memo for each here...
    // ignore: omit_local_variable_types
    List<List<String>> memos = [];
    // ignore: omit_local_variable_types
    for (List<ScripthashHistory> scripthashHistories in histories) {
      // ignore: omit_local_variable_types
      List<Transaction> scripthashTransactions = await client.getTransactions(
          scripthashHistories.map((history) => history.txHash).toList());
      var scripthashMemos = scripthashTransactions
          .map((Transaction scripthashTransaction) =>
              praseTxForMemo(scripthashTransaction))
          .toList();
      memos.add(scripthashMemos);
    }

    return ScripthashHistoriesData(
        scripthashes, histories, unspents, assetUnspents, memos);
  }

  Future saveScripthashHistoryData(ScripthashHistoriesData data) async {
    for (var row in data.zipped) {
      await histories.saveAll(combineHistoryAndUnspents(row));
    }
  }

  List<History> combineHistoryAndUnspents(ScripthashHistoryRow row) {
    var newHistories = <History>[];
    for (var historyMemo in zip([row.history, row.memo])) {
      newHistories.add(History.fromScripthashHistory(
          row.scripthash, historyMemo[0] as ScripthashHistory,
          memo: historyMemo[1] as String));
    }
    for (var unspentMemo in zip([row.unspent, row.memo])) {
      newHistories.add(History.fromScripthashUnspent(
          row.scripthash, unspentMemo[0] as ScripthashUnspent,
          memo: unspentMemo[1] as String));
    }
    for (var assetUnspentMemo in zip([row.assetUnspent, row.memo])) {
      newHistories.add(History.fromScripthashUnspent(
          row.scripthash, assetUnspentMemo[0] as ScripthashUnspent,
          memo: assetUnspentMemo[1] as String));
    }
    return newHistories;
  }
}
