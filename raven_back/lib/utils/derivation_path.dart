import '../records/node_exposure.dart';

String getDerivationPath(int index,
    {exposure = NodeExposure.External, leaderWalletIndex = 0}) {
  var derivationBase = "m/44'/175'";
  return "$derivationBase/$leaderWalletIndex'/"
      '${exposureToDerivationPathPart(exposure)}/$index';
}

String exposureToDerivationPathPart(NodeExposure exposure) {
  switch (exposure) {
    case NodeExposure.External:
      return '0';
    case NodeExposure.Internal:
      return '1';
  }
}
