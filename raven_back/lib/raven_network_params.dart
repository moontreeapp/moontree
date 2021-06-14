import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'wallet_exposure.dart';

class RavenNetworkParams {
  String name;
  bool testnet;
  NetworkType network;
  String derivationBase;

  RavenNetworkParams({
    required this.name,
    required this.testnet,
    required this.network,
    required this.derivationBase,
  });

  String derivationPath(int index, {exposure = WalletExposure.External}) {
    return '$derivationBase/${exposureToDerivationPathPart(exposure)}/$index';
  }

  @override
  String toString() {
    return 'RavenNetworkParams{name: $name, testnet: $testnet, network: ${network.toString()}, derivationPath: $derivationPath';
  }
}
