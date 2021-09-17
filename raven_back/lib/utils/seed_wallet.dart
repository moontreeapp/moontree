import 'dart:typed_data';

import 'package:ravencoin/ravencoin.dart' show HDWallet;

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
