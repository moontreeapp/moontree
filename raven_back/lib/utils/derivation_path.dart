import '../records/node_exposure.dart';

/// what does the derived path of a leader wallet look like?
String getDerivationPathForLeader(int leaderWalletIndex) {
  return 'rvn/$leaderWalletIndex';
}

String getDerivationPath(int index, {exposure = NodeExposure.External}) {
  return "m/44'/175'/0'/"
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
