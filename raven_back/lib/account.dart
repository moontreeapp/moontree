import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:raven/network_params.dart';
import 'network_params.dart';

export 'raven_networks.dart';

class Account {
  final NetworkParams params;
  final HDWallet _wallet;
  final Uint8List seed;

  Account(this.params, {required this.seed})
      : _wallet = HDWallet.fromSeed(seed, network: params.network);

  _HDNode node(int index, {exposure = NodeExposure.External}) {
    var wallet =
        _wallet.derivePath(params.derivationPath(index, exposure: exposure));
    return _HDNode(params, wallet, index, exposure);
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
