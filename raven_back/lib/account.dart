import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:raven/network_params.dart';
import 'network_params.dart';
import 'package:raven/electrum_client.dart';

export 'raven_networks.dart';

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
        print(leaf.balance);
        if (leaf.balance['confirmed'] + leaf.balance['unconfirmed'] == 0) {
          count = count + 1;
          leaf.utxos = [];
        } else {
          count = 0;
          // this address has a balance, we should save it to our utxo set and subscribe to it's status changes...
          // var this.subscription_channel.append... = await client.subscribeTo(scriptHash: leaf.scriptHash);
          leaf.utxos = await client.getUTXOs(scriptHash: leaf.scriptHash);
          print(leaf.utxos);
          // btw we're going to have to call getUTXOs again when creating transactions - so why save it here?
          // I think because we're going to want to query UTXOs quickly to get like all the small ones or stuff...
          // this is all to save on bandwidth to the electrum client because that will be the biggest problem for user experience...
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

  Future<double> getBalance(ElectrumClient client) async {
    if (_internals.isEmpty || _externals.isEmpty) {
      await deriveNodes(client);
    }
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
  var balance;
  var utxos;

  _HDNode(this.params, this.wallet, this.index, this.exposure);

  Uint8List get outputScript {
    return Address.addressToOutputScript(wallet.address, params.network);
  }

  String get scriptHash {
    Digest digest = sha256.convert(outputScript);
    var hash = reverse(digest.bytes);
    return hex.encode(hash);
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
