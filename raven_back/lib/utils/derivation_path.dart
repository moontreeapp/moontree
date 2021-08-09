import '../records/node_exposure.dart';

/// what does the derived path of a leader wallet look like?
String getDerivationPathForLeader(int leaderWalletIndex) {
  return "m/44'/175'/$leaderWalletIndex'";
  //return "m/44'/175'/$leaderWalletIndex'/";
  //return "m/44'/175'/$leaderWalletIndex'/-1/-1";
}

String getDerivationPath(int index,
    {exposure = NodeExposure.External, leaderWalletIndex = 0}) {
  return "m/44'/175'/$leaderWalletIndex'/"
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
