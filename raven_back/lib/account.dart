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
  /* must discuss with Duane:
  why not generate all the nodes (addresses of the wallet) at once at the beginning? 
  And when we do we can attach things to the node objects like utxos and confirmed balance etc.
  we're already generating them when we call getBalance but then we throw them away.
  we'll need to cal getBalance on the entire account first thing when people access the wallet in the UI...
  So why not keep them as individual objects with attributes we care about rather than producing an indexed list of
  attributes that corresponds to them?... this is optimization, but is it premature?
  List<_HDNode> _intnerals = [];
  List<_HDNode> _externals = [];
  */

  // final Map<NodeExposure, List<UTXO>> cache = {};
  final List<CachedNode> cache = [];

  // final List<_HDNode> _internals = [];
  // final List<_HDNode> _externals = [];

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

  Future<bool> deriveNodes(ElectrumClient client) async {
    /*
    fills _internals and _externals lists with _HDNode objects and 
    queries the client for information about each one, saves to node.
    */
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
          unspent = await client.getUTXOs(scriptHash: leaf.scriptHash);
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

  List<UTXO> collectUTXOs(int amount, [List<UTXO>? except]) {
    /*
    tests reveal this isn't quite right - still investigating

    return a sublist of utxos containing at least 0, 1 or more elements:
    [] - insufficient funds
    [...] - the smallest number of inputs to satisfy the amount
    */
    checkCacheEmpty();
    var utxos = generateSortedUTXO(except ?? []);
    var ret = <UTXO>[];
    // Insufficient funds?
    //var total = utxos.reduce((a, b) => (a['value'] + b['value']).toInt());  //why no work?
    var availableFunds = 0;
    utxos.forEach((item) {
      availableFunds = (availableFunds + item.unspent.value).toInt();
    });
    if (availableFunds < amount) {
      throw InsufficientFunds();
      //return ret;
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
    var remaining = amount;
    for (var i = utxos.length - 1; i >= 0; i--) {
      if (remaining < utxos[i].unspent.value) {
        break;
      }
      ret.add(utxos[i]);
      remaining = (remaining - utxos[i].unspent.value).toInt();
    }

    // Find one last UTXO, starting from smallest, that satisfies the remainder
    ret.add(utxos.firstWhere((utxo) => utxo.unspent.value >= remaining));

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
