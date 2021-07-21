import 'package:ravencoin/ravencoin.dart';
import 'records/node_exposure.dart';

final Map derivationPath = {
  ravencoin.wif: "m/44'/175'/0'",
  testnet.wif: "m/44'/175'/1'"
};

String getDerivationPath(int index,
    {exposure = NodeExposure.External, wif = 0xef}) {
  if (!derivationPath.containsKey(wif)) {
    throw ArgumentError('Unknown WIF network identifier: $wif');
  }
  var derivationBase = derivationPath[wif];
  return '$derivationBase/${exposureToDerivationPathPart(exposure)}/$index';
}

String exposureToDerivationPathPart(NodeExposure exposure) {
  switch (exposure) {
    case NodeExposure.External:
      return '0';
    case NodeExposure.Internal:
      return '1';
  }
}
