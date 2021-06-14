import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:raven/wallet_exposure.dart';
import 'raven_network_params.dart';

class RavenWallet {
  final RavenNetworkParams _params;
  final HDWallet _wallet;

  RavenWallet(params, wallet)
      : _params = params,
        _wallet = wallet;

  HDWallet getHDWallet(int index, {exposure = WalletExposure.External}) {
    return _wallet
        .derivePath(_params.derivationPath(index, exposure: exposure));
  }
}
