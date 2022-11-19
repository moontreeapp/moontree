import 'dart:typed_data';

import 'package:wallet_utils/wallet_utils.dart' show HDWallet, KPWallet;

import 'package:ravencoin_back/utilities/derivation_path.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

class SeedWallet {
  Uint8List seed;
  Chain chain;
  Net net;

  SeedWallet(this.seed, this.chain, this.net);

  HDWallet get wallet =>
      HDWallet.fromSeed(seed, network: networkOf(chain, net));

  HDWallet subwallet(int hdIndex, {exposure = NodeExposure.external}) =>
      wallet.derivePath(getDerivationPath(
        hdIndex,
        exposure: exposure,
        net: net,
      ));
}

class SingleSelfWallet {
  String wif;

  SingleSelfWallet(this.wif);

  KPWallet get wallet {
    return KPWallet.fromWIF(wif, pros.settings.network);
  }
}
