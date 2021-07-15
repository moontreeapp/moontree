import 'package:ravencoin/ravencoin.dart';
import 'account.dart';

class NetworkParams {
  String name;
  bool testnet;
  NetworkType network;
  String derivationBase;

  NetworkParams({
    required this.name,
    required this.testnet,
    required this.network,
    required this.derivationBase,
  });

  String derivationPath(int index, {exposure = NodeExposure.External}) {
    return '$derivationBase/${exposureToDerivationPathPart(exposure)}/$index';
  }

  @override
  String toString() {
    return 'NetworkParams{name: $name, testnet: $testnet, network: ${network.toString()}, derivationPath: $derivationPath';
  }
}
