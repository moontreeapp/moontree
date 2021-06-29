import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:raven/network_params.dart';
import 'network_params.dart';
import 'package:raven/electrum_client.dart';

export 'raven_networks.dart';

class CacheEmpty implements Exception {
  String cause;
  CacheEmpty([this.cause = 'Error! Please deriveNodes first.']);
}

class InsufficientFunds implements Exception {
  String cause;
  InsufficientFunds([this.cause = 'Error! Insufficient funds.']);
}

class CachedNode {
  _HDNode node;
  ScriptHashBalance balance;
  List<ScriptHashUnspent> unspent;
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
  final HDWallet _wallet;
  final Uint8List seed;
  final int gap;
  final List<CachedNode> cache = [];

  Account(this.params, {required this.seed, this.gap = 20})
      : _wallet = HDWallet.fromSeed(seed, network: params.network);

  _HDNode node(int index, {exposure = NodeExposure.External}) {
    var wallet =
        _wallet.derivePath(params.derivationPath(index, exposure: exposure));
    return _HDNode(params, wallet, index, exposure);
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

  /// fills cache from electrum server, to be called before anything else
  Future<bool> deriveNodes(ElectrumClient client) async {
    _HDNode leaf;
    for (var exposure in NodeExposure.values) {
      var count = 0;
      var nodeIndex = 0;
      while (count < gap) {
        leaf = node(nodeIndex, exposure: exposure);
        var balance = await client.getBalance(scriptHash: leaf.scriptHash);
        var history = await client.getHistory(scriptHash: leaf.scriptHash);
        var unspent = [ScriptHashUnspent.empty()];
        if (balance.value == 0) {
          if (history.isEmpty) {
            count = count + 1;
          } else {
            count = 0;
          }
        } else {
          count = 0;
          // this address has a balance, we should save it to our utxo set and subscribe to it's status changes...
          // var this.subscription_channel.append... = await client.subscribeTo(scriptHash: leaf.scriptHash);
          unspent = await client.getUnspent(scriptHash: leaf.scriptHash);
        }
        var cachedNode = CachedNode(leaf,
            balance: balance, history: history, unspent: unspent);
        cache.add(cachedNode);
        nodeIndex = nodeIndex + 1;
      }
    }
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

  /// returns the next internal node without a history
  _HDNode getNextChangeNode() {
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

class _HDNode {
  NetworkParams params;
  HDWallet wallet;
  int index;
  NodeExposure exposure;
  ScriptHashBalance? balance;
  List? history;
  List? utxos;

  _HDNode(this.params, this.wallet, this.index, this.exposure,
      [this.balance, this.history, this.utxos]);

  Uint8List get outputScript {
    return Address.addressToOutputScript(wallet.address, params.network);
  }

  String get scriptHash {
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
