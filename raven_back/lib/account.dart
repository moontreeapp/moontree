import 'dart:cli';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'network_params.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';
export 'raven_networks.dart';
import 'boxes.dart' as boxes;

class CacheEmpty implements Exception {
  String cause;
  CacheEmpty([this.cause = 'Error! Please deriveNodes first.']);
}

class InsufficientFunds implements Exception {
  String cause;
  InsufficientFunds([this.cause = 'Error! Insufficient funds.']);
}

//@HiveType(typeId: 0)
class CachedNode {
  //@HiveField(0)
  HDNode node;

  //@HiveField(1)
  ScriptHashBalance balance;

  //@HiveField(2)
  List<ScriptHashUnspent> unspent;

  //@HiveField(3)
  List<ScriptHashHistory> history;

  CachedNode(this.node,
      {required this.balance, required this.unspent, required this.history});
}

class UTXO {
  ScriptHashUnspent unspent;
  NodeExposure exposure;
  int nodeIndex;

  UTXO(this.unspent, this.exposure, this.nodeIndex);
}

class Account {
  final NetworkParams params;
  final Uint8List seed;
  final String name;
  final HDWallet _wallet;
  final List<CachedNode> cache = [];
  final String uid;

  Account(this.params, {required this.seed, this.name = 'First Wallet'})
      : _wallet = HDWallet.fromSeed(seed, network: params.network),
        uid = sha256.convert(seed).toString();

  HDNode node(int index, {exposure = NodeExposure.External}) {
    var wallet =
        _wallet.derivePath(params.derivationPath(index, exposure: exposure));
    return HDNode(params, wallet, index, exposure);
  }

  List<CachedNode> get internals {
    var internals = List<CachedNode>.from(cache);
    internals
        .retainWhere((utxo) => utxo.node.exposure == NodeExposure.Internal);
    return internals;
  }

  List<CachedNode> get externals {
    var externals = List<CachedNode>.from(cache);
    externals
        .retainWhere((utxo) => utxo.node.exposure == NodeExposure.External);
    return externals;
  }

  /// triggered by watching accounts box and script hashes we care about?
  Future driveBatch(List existingNodes, NodeExposure exposure,
      [int batchSize = 10]) async {
    var nodes = await boxes.Truth.instance.open('nodes');
    var index = existingNodes.length;
    //var exposure = existingNodes.isNotEmpty ? existingNodes[existingNodes.length - 1] : NodeExposure.Internal;
    for (var i = 0; i < batchSize; i++) {
      existingNodes.add({
        'exposure': exposure,
        'index': index,
        'scriptHash': node(index, exposure: exposure).scriptHash
      });
      index = index + 1;
    }
    await nodes.put(uid, existingNodes);
    await nodes.close();
  }

  /// fills cache from electrum server, to be called before anything else
  Future<bool> deriveNodes(RavenElectrumClient client) async {
    var nodeBalances = await boxes.Truth.instance.open('balances');
    // ignore: todo
    // if possible separate batching our batches concern from get data
    HDNode leaf;
    var batchSize = 10;
    for (var exposure in NodeExposure.values) {
      var nodeIndex = 0;
      var entireBatchEmpty = false;
      while (!entireBatchEmpty) {
        // ignore: omit_local_variable_types
        List<String> batch = [];
        var leaves = [];
        for (var i = 0; i < batchSize; i++) {
          leaf = node(nodeIndex, exposure: exposure);
          nodeIndex = nodeIndex + 1;
          batch.add(leaf.scriptHash);
          leaves.add(leaf);
        }
        var balances = await client.getBalances(scriptHashes: batch);
        var histories = await client.getHistories(scriptHashes: batch);
        var unspents = await client.getUnspents(scriptHashes: batch);
        // ignore: todo
        // subscribe this this scripthash
        entireBatchEmpty = true;
        for (var i = 0; i < batch.length; i++) {
          if (histories[i].isNotEmpty) entireBatchEmpty = false;
          leaf = leaves[i];
          var cachedNode = CachedNode(leaf,
              balance: balances[i],
              history: histories[i],
              unspent: (unspents[i].isEmpty)
                  ? [ScriptHashUnspent.empty()]
                  : unspents[i]);
          cache.add(cachedNode);
          await nodeBalances.put(
              uid +
                  exposure.toString() +
                  ((nodeIndex - batchSize) + i).toString(),
              balances[i]);
        }
      }
    }
    await nodeBalances.close();
    return true;
  }

  void checkCacheEmpty() {
    if (cache.isEmpty) throw CacheEmpty();
  }

  int getBalance() {
    checkCacheEmpty();
    return cache.fold(
        0,
        (int previousValue, CachedNode element) =>
            previousValue + element.balance.value);
  }

  Future<int> getBalanceFromDatabase() async {
    return await boxes.Truth.instance.getAccountBalance(this);
  }

  /// returns the next internal node without a history
  HDNode getNextChangeNode() {
    checkCacheEmpty();
    var i = 0;
    for (i = 0; i < internals.length; i++) {
      if (internals[i].history.isEmpty) {
        return internals[i].node;
      }
    }
    return node(i + 1, exposure: NodeExposure.Internal);
  }

  /// Returns a sorted, flattened list of UTXOs derived from cache
  List<UTXO> generateSortedUTXO(List<UTXO> except) {
    var cachedNodes = List<CachedNode>.from(cache);
    var unflattenedUtxos = cachedNodes.map((CachedNode n) => n.unspent
        .map((unspent) => UTXO(unspent, n.node.exposure, n.node.index)));

    // Flatten the list of lists
    var utxos = unflattenedUtxos.expand((element) => element).toList();

    // Sort by smallest to largest UTXO value
    utxos.sort((UTXO a, UTXO b) => a.unspent.value.compareTo(b.unspent.value));

    // We don't want to include UTXOs that have already been included to be spent
    utxos.removeWhere((utxo) => except.contains(utxo));

    return utxos;
  }

  /// returns the smallest number of inputs to satisfy the amount
  List<UTXO> collectUTXOs(int amount, [List<UTXO>? except]) {
    checkCacheEmpty();
    var utxos = generateSortedUTXO(except ?? []);
    var ret = <UTXO>[];

    // Insufficient funds?
    var availableFunds = 0;
    utxos.forEach((item) {
      availableFunds = (availableFunds + item.unspent.value).toInt();
    });
    if (availableFunds < amount) {
      throw InsufficientFunds();
    }

    // can we find an ideal singular utxo?
    for (var i = 0; i < utxos.length; i++) {
      if (utxos[i].unspent.value >= amount) {
        return [utxos[i]];
      }
    }

    // what combinations of utxo's must we return?
    // lets start by grabbing the largest one
    // because we know we can consume it all without producing change...
    // and lets see how many times we can do that
    var remainder = amount;
    for (var i = utxos.length - 1; i >= 0; i--) {
      if (remainder < utxos[i].unspent.value) {
        break;
      }
      ret.add(utxos[i]);
      remainder = (remainder - utxos[i].unspent.value).toInt();
    }
    // Find one last UTXO, starting from smallest, that satisfies the remainder
    ret.add(utxos.firstWhere((utxo) => utxo.unspent.value >= remainder));
    return ret;
  }
}

List<int> reverse(List<int> hex) {
  var buffer = Uint8List(hex.length);
  for (var i = 0, j = hex.length - 1; i <= j; ++i, --j) {
    buffer[i] = hex[j];
    buffer[j] = hex[i];
  }
  return buffer;
}

class HDNode {
  NetworkParams params;
  HDWallet wallet;
  int index;
  NodeExposure exposure;

  HDNode(this.params, this.wallet, this.index, this.exposure);

  Uint8List get outputScript {
    return Address.addressToOutputScript(wallet.address, params.network);
  }

  String get scriptHash {
    // ignore: omit_local_variable_types
    Digest digest = sha256.convert(outputScript);
    var hash = reverse(digest.bytes);
    return hex.encode(hash);
  }

  ECPair get keyPair {
    return ECPair.fromWIF(wallet.wif, network: params.network);
  }
}

enum NodeExposure { Internal, External }

String exposureToDerivationPathPart(NodeExposure exposure) {
  switch (exposure) {
    case NodeExposure.External:
      return '0';
    case NodeExposure.Internal:
      return '1';
  }
}
