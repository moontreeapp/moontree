import 'dart:typed_data';
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:raven/raven_wallet.dart';

import 'raven_network_params.dart';

export 'raven_networks.dart';

class RavenNetwork {
  RavenNetworkParams params;

  RavenNetwork(this.params);

  RavenWallet getRavenWallet(Uint8List seed) {
    return RavenWallet(
        params, HDWallet.fromSeed(seed, network: params.network));
  }
}
