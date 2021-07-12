import 'package:hive/hive.dart';
import 'package:quiver/iterables.dart';
import 'package:sorted_list/sorted_list.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'account.dart';
import 'accounts.dart';
import 'boxes.dart' as boxes;

/// triggered by watching nodes
Future requestBalance(String scripthash) async {
  var client = await RavenElectrumClient.connect('testnet.rvn.rocks');
  var balance = await client.getBalance(scripthash);
  await boxes.Truth.instance.balances.put(scripthash, balance);
}

/// triggered by watching nodes
Future requestBalances(List<String> batch) async {
  var client = await RavenElectrumClient.connect('testnet.rvn.rocks');
  var balances = await client.getBalances(batch);
  for (var hashBalance in zip([batch, balances]).toList()) {
    await boxes.Truth.instance.balances.put(hashBalance[0], hashBalance[1]);
  }
}

/// triggered by watching nodes
Future requestHistory(String scripthash, String accountId,
    {exposure = NodeExposure.Internal}) async {
  var client = await RavenElectrumClient.connect('testnet.rvn.rocks');
  var histories = await client.getHistory(scripthash);
  var entireBatchEmpty = true;
  if (histories.isNotEmpty) entireBatchEmpty = false;
  await boxes.Truth.instance.histories.put(scripthash, histories);
  if (!entireBatchEmpty) {
    await Accounts.instance.accounts[accountId]!.deriveBatch(exposure);
  }
}

/// triggered by watching nodes
Future requestHistories(List<String> batch, String accountId,
    {exposure = NodeExposure.Internal}) async {
  var client = await RavenElectrumClient.connect('testnet.rvn.rocks');
  var histories = await client.getHistories(batch);
  var entireBatchEmpty = true;
  for (var hashHistory in zip([batch, histories]).toList()) {
    if (hashHistory[1].isNotEmpty) entireBatchEmpty = false;
    await boxes.Truth.instance.histories.put(hashHistory[0], hashHistory[1]);
  }
  if (!entireBatchEmpty) {
    await Accounts.instance.accounts[accountId]!.deriveBatch(exposure);
  }
}

/// triggered by watching nodes
Future requestUnspent(String scripthash) async {
  var client = await RavenElectrumClient.connect('testnet.rvn.rocks');
  var unspents = await client.getUnspent(scripthash);
  await boxes.Truth.instance.unspents.put(scripthash, unspents);
}

/// triggered by watching nodes
Future requestUnspents(List<String> batch) async {
  var client = await RavenElectrumClient.connect('testnet.rvn.rocks');
  var unspents = await client.getUnspents(batch);
  for (var hashUnspents in zip([batch, unspents]).toList()) {
    await boxes.Truth.instance.unspents.put(hashUnspents[0], hashUnspents[1]);
  }
}

/// triggered by unspents
/// sorts a flattened list of all unspents on an account
Future sortUnspents(String accountId, List<ScripthashUnspent> utxos) async {
  // implemented as incremental load
  // alternatively could grab all utxo's for accountId each time...
  var accountUnspentsBox = boxes.Truth.instance.accountUnspents;
  var sortedList = accountUnspentsBox.get(accountId) ??
      SortedList<ScripthashUnspent>(
          (ScripthashUnspent a, ScripthashUnspent b) =>
              a.value.compareTo(b.value));
  sortedList.addAll(utxos);
  await accountUnspentsBox.put(accountId, sortedList);
}
