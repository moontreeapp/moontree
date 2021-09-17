import 'dart:typed_data';

import 'package:ravencoin/ravencoin.dart' show HDWallet, KPWallet, NetworkType;

import 'package:raven/utils/derivation_path.dart';
import 'package:raven/raven.dart';

class SeedWallet {
  Uint8List seed;
  Net net;

  SeedWallet(this.seed, this.net);

  HDWallet get wallet => HDWallet.fromSeed(seed, network: networks[net]!);

  HDWallet subwallet(int hdIndex, {exposure = NodeExposure.External}) =>
      wallet.derivePath(getDerivationPath(hdIndex, exposure: exposure));
}

class SingleSelfWallet {
  String wif;
  // Net net; // unnecessary

  SingleSelfWallet(this.wif);

  KPWallet get wallet {
    var x = 0;
    var nets = <int, NetworkType>{};
    for (MapEntry kv in networks.entries) {
      nets[x] = kv.value;
      x = x + 1;
    }
    // why does this take a map of networks instead of a specific network?
    return KPWallet.fromWIF(wif, networks: nets);
  }
}
