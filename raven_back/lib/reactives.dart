import 'package:quiver/iterables.dart';
import 'package:sorted_list/sorted_list.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'boxes.dart' as boxes;

/// triggered by watching nodes
Future requestBalance(List<String> batch) async {
  var client = await RavenElectrumClient.connect('testnet.rvn.rocks');
  var nodesBalance = await boxes.Truth.instance.open('balances');
  var balances = await client.getBalances(scriptHashes: batch);
  for (var hashBalance in zip([batch, balances]).toList()) {
    await nodesBalance.put(hashBalance[0], hashBalance[1]);
  }
  await nodesBalance.close();
}

/// triggered by watching nodes
Future requestUnspents(List<String> batch) async {
  var client = await RavenElectrumClient.connect('testnet.rvn.rocks');
  var nodesUnspents = await boxes.Truth.instance.open('unspents');
  var unspents = await client.getUnspents(scriptHashes: batch);
  for (var hashUnspents in zip([batch, unspents]).toList()) {
    await nodesUnspents.put(hashUnspents[0], hashUnspents[1]);
  }
  await nodesUnspents.close();
}

/// triggered by unspents
/// sorts a flattened list of all unspents on an account
Future sortUnspents(
    String uid, String scriptHash, List<ScriptHashUnspent> utxos) async {
  // this isn't coded right it sorts it for just one node...
  var sortedList = SortedList<ScriptHashUnspent>(
      (ScriptHashUnspent a, ScriptHashUnspent b) => a.value.compareTo(b.value));
  sortedList.addAll(utxos);
  var nodesUTXOs = await boxes.Truth.instance.open('utxos');
  await nodesUTXOs.put(scriptHash, sortedList);
  await nodesUTXOs.close();
}
