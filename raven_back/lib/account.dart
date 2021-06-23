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
  CacheEmpty([this.cause = 'error! please deriveNodes first.']);
}

class Account {
  final NetworkParams params;
  final HDWallet _wallet;
  final Uint8List seed;
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
  final _internals = [];
  final _externals = [];

  Account(this.params, {required this.seed})
      : _wallet = HDWallet.fromSeed(seed, network: params.network);

  _HDNode node(int index, {exposure = NodeExposure.External}) {
    var wallet =
        _wallet.derivePath(params.derivationPath(index, exposure: exposure));
    return _HDNode(params, wallet, index, exposure);
  }

  List getInternals() {
    return _internals;
  }

  List getExternals() {
    return _externals;
  }

  Future<bool> deriveNodes(ElectrumClient client) async {
    /*
    fills _internals and _externals lists with _HDNode objects and 
    queries the client for information about each one, saves to node.
    */
    var gap = 20;
    var c = 0;
    var count = 0;
    var exposures = [NodeExposure.Internal, NodeExposure.External];
    var leaf;
    while (count < gap) {
      for (var i = 0; i < exposures.length; i++) {
        leaf = node(c, exposure: exposures[i]);
        leaf.balance = await client.getBalance(scriptHash: leaf.scriptHash);
        leaf.history = await client.getHistory(scriptHash: leaf.scriptHash);
        if (leaf.balance['confirmed'] + leaf.balance['unconfirmed'] == 0) {
          // would be better to modify code where this is used to accept empty list:
          leaf.utxos = [
            {'tx_hash': '', 'tx_pos': -1, 'height': -1, 'value': 0}
          ];
          if (leaf.history.isEmpty) {
            count = count + 1;
          } else {
            count = 0;
          }
        } else {
          count = 0;
          // this address has a balance, we should save it to our utxo set and subscribe to it's status changes...
          // var this.subscription_channel.append... = await client.subscribeTo(scriptHash: leaf.scriptHash);
          leaf.utxos = await client.getUTXOs(scriptHash: leaf.scriptHash);
        }
        if (exposures[i] == NodeExposure.Internal) {
          _internals.add(leaf);
        } else {
          _externals.add(leaf);
        }
      }
      c = c + 1;
    }
    return true;
  }

  void checkCacheEmpty() {
    if (_internals.isEmpty || _externals.isEmpty) {
      throw CacheEmpty();
    }
  }

  double getBalance() {
    checkCacheEmpty();
    var total = 0.0;
    for (var i = 0; i < _internals.length; i++) {
      total = total +
          _internals[i].balance['confirmed'] +
          _internals[i].balance['unconfirmed'];
    }
    for (var i = 0; i < _externals.length; i++) {
      total = total +
          _externals[i].balance['confirmed'] +
          _externals[i].balance['unconfirmed'];
    }
    return total;
  }

  _HDNode getNextChangeNode() {
    /* returns the next internal node without a history */
    checkCacheEmpty();
    var c = 0;
    for (var i = 0; i < _internals.length; i++) {
      if (_internals[i].history.isEmpty) {
        return _internals[i];
      }
      c = c + 1;
    }
    return node(c, exposure: NodeExposure.Internal);
  }

  List generateSortedUTXO([List? except]) {
    /*
    _internal and _external contain nodes
    each node has a utxo list, for example:    
    node3.utxo = [{tx_hash: 8...3, tx_pos: 1, height: 765913, value: 5000087912000}]
    
    this function: 
    1. extracts all those lists and combines them,
    2. appends more data to them about node index and exposure,
    3. and sorts them smallest to largest:
    -->
    [
      {tx_hash: , tx_pos: -1, height: -1, value: 0, node: 0, exposure: NodeExposure.Internal},
      {tx_hash: 2...5, tx_pos: 0, height: 769767, value: 4000000, node: 0, exposure: NodeExposure.External},
      {tx_hash: 8...3, tx_pos: 1, height: 765913, value: 5000087912000, node: 3, exposure: NodeExposure.Internal},
      ...
    ]
    */
    except = except ?? [];
    var c = 0;
    var allutxos = [];
    for (var i = 0; i < _internals.length; i++) {
      for (var j = 0; j < _internals[i].utxos.length; j++) {
        if (!except.contains(_externals[i].utxos[j])) {
          allutxos.add(_internals[i].utxos[j]);
          allutxos[c]['node'] = i;
          allutxos[c]['exposure'] = NodeExposure.Internal;
          c = c + 1;
        }
      }
    }
    for (var i = 0; i < _externals.length; i++) {
      for (var j = 0; j < _externals[i].utxos.length; j++) {
        if (!except.contains(_externals[i].utxos[j])) {
          allutxos.add(_externals[i].utxos[j]);
          allutxos[c]['node'] = i;
          allutxos[c]['exposure'] = NodeExposure.External;
          c = c + 1;
        }
      }
    }
    allutxos.sort((a, b) => a['value'].compareTo(b['value']));
    return allutxos;
  }

  List collectUTXOs(int amount, [List? except]) {
    /*
    return a sublist of utxos containing at least 0, 1 or more elements:
    [] - insufficient funds
    [...] - the smallest number of inputs to satisfy the amount
    */
    checkCacheEmpty();
    var utxos = generateSortedUTXO(except);
    var ret = [];
    // Insufficient funds?
    var total = utxos.reduce((a, b) => a + b);
    if (total >= amount) {
      return ret;
    }
    // can we find an ideal singular utxo?
    for (var i = 0; i < utxos.length; i++) {
      if (utxos[i]['value'] >= amount) {
        return [utxos[i]];
      }
    }
    // what combinations of utxo's must we return?
    for (var i = 0; i < utxos.length; i++) {
      //??
    }

    var ideal = {}; // smallest value larger than amount
    for (var i = 0; i < _internals.length; i++) {
      for (var j = 0; j < _internals[i].utxos.length; j++) {
        if (_internals[i].utxos[j]['value'] > amount &&
            (ideal.isEmpty ||
                _internals[i].utxos[j]['value'] < ideal['value'])) {
          if (!except.contains(_internals[i].utxos[j])) {
            ideal = _internals[i].utxos[j];
            ideal['exposure'] = NodeExposure.Internal;
            ideal['node index'] = i;
          }
        }
      }
    }
    for (var i = 0; i < _externals.length; i++) {
      for (var j = 0; j < _externals[i].utxos.length; j++) {
        if (_externals[i].utxos[j]['value'] > amount &&
            (ideal.isEmpty ||
                _externals[i].utxos[j]['value'] < ideal['value'])) {
          if (!except.contains(_externals[i].utxos[j])) {
            ideal = _externals[i].utxos[j];
            ideal['exposure'] = NodeExposure.External;
            ideal['node index'] = i;
          }
        }
      }
    }
    if (ideal.isNotEmpty) {
      return [ideal];
    }
    // we looked for the best singular utxo and didn't find it... returning a list of them.
    // consume largest first? or oldest first? or in order? in order for now.
    //var largestInternals = _internals.map((item) {
    //  return item.utxos;
    //}).toList();
    //largestInternals.sort(...)
    var utxos = [];
    var total = 0.0;
    for (var i = 0; i < _internals.length; i++) {
      if (total > amount) {
        break;
      }
      for (var j = 0; j < _internals[i].utxos.length; j++) {
        if (_internals[i].utxos[j]['value'] > 0) {
          if (!except.contains(_internals[i].utxos[j])) {
            total = total + _internals[i].utxos[j]['value'];
            ideal = _internals[i].utxos[j];
            ideal['exposure'] = NodeExposure.Internal;
            ideal['node index'] = i;
            utxos.add(ideal);
            if (total > amount) {
              break;
            }
          }
        }
      }
    }
    for (var i = 0; i < _externals.length; i++) {
      if (total > amount) {
        break;
      }
      for (var j = 0; j < _externals[i].utxos.length; j++) {
        if (_externals[i].utxos[j]['value'] > 0) {
          if (!except.contains(_externals[i].utxos[j])) {
            total = total + _externals[i].utxos[j]['value'];
            ideal = _externals[i].utxos[j];
            ideal['exposure'] = NodeExposure.External;
            ideal['node index'] = i;
            utxos.add(ideal);
            if (total > amount) {
              break;
            }
          }
        }
      }
    }
    if (total >= amount) {
      return utxos;
    }
    // error? insufficient funds?
    return [];
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
  Map? balance;
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
