import 'package:quiver/iterables.dart';
import 'package:raven/models.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'accounts.dart';
import 'boxes.dart';
import '../records/node_exposure.dart';

Future<List> getReport(String scripthash, RavenElectrumClient client,
    NodeExposure exposure) async {
  var history = await client.getHistory(scripthash);
  var report = Report(scripthash, await client.getBalance(scripthash), history,
      await client.getUnspent(scripthash));
  // trigger new wallet derivation if not empty
  return [report, history.isNotEmpty];
}

/// triggered by watching nodes
Future requestBalance(String scripthash, RavenElectrumClient client) async {
  var balance = await client.getBalance(scripthash);
  await Truth.instance.balances.put(scripthash, balance);
}

/// triggered by watching nodes
Future requestBalances(List<String> batch, RavenElectrumClient client) async {
  var balances = await client.getBalances(batch);
  for (var hashBalance in zip([batch, balances]).toList()) {
    await Truth.instance.balances.put(hashBalance[0], hashBalance[1]);
  }
}

/// triggered by watching nodes
Future requestHistory(
    String scripthash, String accountId, RavenElectrumClient client,
    {exposure = NodeExposure.Internal}) async {
  var histories = await client.getHistory(scripthash);
  var entireBatchEmpty = true;
  if (histories.isNotEmpty) entireBatchEmpty = false;
  await Truth.instance.histories.put(scripthash, histories);
  if (!entireBatchEmpty) {
    await Accounts.instance.accounts[accountId]!
        .deriveAddress(0, exposure); // broken
  }
}

/// triggered by watching nodes
Future requestHistories(
    List<String> batch, String accountId, RavenElectrumClient client,
    {exposure = NodeExposure.Internal}) async {
  var histories = await client.getHistories(batch);
  var entireBatchEmpty = true;
  for (var hashHistory in zip([batch, histories]).toList()) {
    if (hashHistory[1].isNotEmpty) entireBatchEmpty = false;
    await Truth.instance.histories.put(hashHistory[0], hashHistory[1]);
  }
  if (!entireBatchEmpty) {
    await Accounts.instance.accounts[accountId]!
        .deriveAddress(0, exposure); // broken
  }
}

/// triggered by watching nodes
Future requestUnspent(String scripthash, RavenElectrumClient client) async {
  var unspents = await client.getUnspent(scripthash);
  await Truth.instance.unspents.put(scripthash, unspents);
}

/// triggered by watching nodes
Future requestUnspents(List<String> batch, RavenElectrumClient client) async {
  var unspents = await client.getUnspents(batch);
  for (var hashUnspents in zip([batch, unspents]).toList()) {
    await Truth.instance.unspents.put(hashUnspents[0], hashUnspents[1]);
  }
}

/* not using because hive can't save or open the box as this type
** instead we make a list of them by account and sort it at runtime
/// triggered by unspents
/// sorts a flattened list of all unspents on an account
Future sortUnspents(String accountId, List<ScripthashUnspent> utxos) async {
  // implemented as incremental load
  // alternatively could grab all utxo's for accountId each time...
  var sortedList = Truth.instance.accountUnspents
          .getAsList<ScripthashUnspent>(accountId) ??
      SortedList<ScripthashUnspent>(
          (ScripthashUnspent a, ScripthashUnspent b) =>
              a.value.compareTo(b.value));
  sortedList.addAll(utxos);
  await Truth.instance.accountUnspents.put(accountId, sortedList);
}
*/

/// triggered by unspents
/// flattens list of all unspents on an account
/// implemented as incremental load
Future flattenUnspents(String accountId, List<ScripthashUnspent> utxos) async {
  var flat =
      Truth.instance.accountUnspents.getAsList<ScripthashUnspent>(accountId);
  flat.addAll(utxos);
  await Truth.instance.accountUnspents.put(accountId, flat);
}
