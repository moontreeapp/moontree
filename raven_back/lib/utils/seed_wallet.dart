import 'dart:typed_data';

import 'package:ravencoin/ravencoin.dart' show HDWallet, KPWallet, NetworkType;

import 'package:raven_back/utils/derivation_path.dart';
import 'package:raven_back/raven_back.dart';

class SeedWallet {
  Uint8List seed;
  Net net;

  SeedWallet(this.seed, this.net);

  HDWallet get wallet => HDWallet.fromSeed(seed, network: networks[net]!);

  HDWallet subwallet(int hdIndex, {exposure = NodeExposure.External}) =>
      wallet.derivePath(getDerivationPath(hdIndex, exposure: exposure));
}

/// on import - verify it's being added to an account matching it's Net
class SingleSelfWallet {
  String wif;

  SingleSelfWallet(this.wif);

  KPWallet get wallet {
    return KPWallet.fromWIF(wif);
  }
}
